#!/usr/bin/env python3

import argparse
import os
from pathlib import Path

import yaml
import logging
import sys
from pyartifactory import Artifactory
from collections import ChainMap

import lib.cue_helpers as cue
import lib.helpers as h
import lib.promotion_config as pc

LOGGER = logging.getLogger()

handler = logging.StreamHandler(sys.stdout)
if os.getenv('DEBUG'):
    LOGGER.setLevel(logging.DEBUG)
    handler.setLevel(logging.DEBUG)
else:
    LOGGER.setLevel(logging.INFO)
    handler.setLevel(logging.INFO)

handler.setFormatter(logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s'))
LOGGER.addHandler(handler)

# Read scripts/templates/greymatter-download-template 
# generates a download script using versions in inputs.cue
def generate_download_script(component_version_dict,src_file="scripts/templates/greymatter-download-template", dest_file="greymatter-download.sh"):
    LOGGER.info("starting to generate download script")
    sub_map=sub_map_for_download_script(component_version_dict)
    
    contents=h.read_file(src_file)
    
    # Actually does the sub 
    for i in sub_map:
        contents = contents.replace(i,sub_map.get(i))

    h.write_file(contents,dest_file)
    LOGGER.info("Completed generating download script.  Can be found at [%s]" % dest_file)

def sub_map_for_download_script(component_version_dict):
    sub_map={}
    for k in component_version_dict:
        sub_map["<%s_VERSION>" % k.replace("-","_").upper()]=component_version_dict.get(k)
    return sub_map

# Read inputs.cue and replace src oci with dest oci
def generate_new_input_cue(src_oci, dest_oci, src_file="inputs.cue", dest_file="generated_inputs.cue"):
    LOGGER.info("Starting to generate updated inputs.cue")
    contents=h.read_file(src_file)
    
    contents=contents.replace(src_oci, dest_oci)
    # write modified contents to new file
    h.write_file(contents,dest_file)
    LOGGER.info("Completed generating updated cue.  Can be found at [%s]" % dest_file)

def create_component_version_dict():
    LOGGER.info("Compiling component versions")
    tag_dict={}
    raw_objects=[]
    component_version_dict={}
    component_image_dict={}
    r= cue.cue_eval(tag_dict)
    try:
        LOGGER.debug("Loading Cue Generated JSON")
        load = yaml.safe_load_all(r)
        for i in load:
            raw_objects.append(i)
        LOGGER.debug("Done loading Cue Generated JSON")
    except yaml.YAMLError as e:
        LOGGER.error("Could not load cue generated json.\n%s " % e)
        raise e
    
    mesh_images=raw_objects[0]["mesh"]["spec"]["images"]
    defaults_images=raw_objects[0]["defaults"]["images"]

    images= ChainMap(mesh_images, defaults_images)
    for i in images:
        component=i.replace("_","-")
        version=images.get(i).split(":")[1]
        LOGGER.debug("Found Component: [%s] Version: [%s]" % (component, version))
        component_version_dict[component]=version
        component_image_dict[component]=images.get(i)

    return component_version_dict, component_image_dict

def get_artifact_list(artifact_type, art, component, src):
    comp_full_name="greymatter-%s" % component
    total_component_list=[]
    try:
        search="%s/%s/" % (src, comp_full_name)
        LOGGER.debug("Retrieving list of artifacts in %s" % search)
        match artifact_type:
            case "generic":
                total_component_list = art.artifacts.list("%s/%s" % (src, comp_full_name), list_folders=False, recursive=False)
            # oci needs to list_folders
            case "oci":
                total_component_list = art.artifacts.list("%s/%s" % (src, comp_full_name), list_folders=True, recursive=False)
    except Exception as e:
        LOGGER.error("Was not able to get list of artifacts:\n %s" % e)
        raise e
    return total_component_list

def filter_artifact_list(artifact_type, artifact_full_list, component, component_version):
    comp_full_name="greymatter-%s" % component
    filtered_components=[]
    
    # filter components for just the version
    for i in artifact_full_list.files:
        artifact_name=i.uri.rstrip("/").lstrip("/")
        match artifact_type:
            case "generic":
                if artifact_name.__contains__("%s_%s" % (comp_full_name, component_version)):
                    filtered_components.append(artifact_name)
            # oci needs to filter for the tag version
            case "oci":
                if artifact_name == component_version:
                    filtered_components.append(artifact_name)
        
    return filtered_components

def promote(artifact_type, art, component, component_version, src, dest, dry_run):
    # ensure promotion src and dest could work
    repo_list=[]
    repositories = art.repositories.list()
    for i in repositories:
        repo_list.append(i.key)
    LOGGER.debug("Repo List: %s" % repo_list)
    
    if src not in repo_list:
        raise Exception("Repository [%s] does not exist" % src )
    if dest not in repo_list:
        raise Exception("Repository [%s] does not exist" % dest )

    comp_full_name="greymatter-%s" % component

    artifact_full_list=get_artifact_list(artifact_type, art, component, src )
    artifacts_to_promote=filter_artifact_list(artifact_type, artifact_full_list, component, component_version)

    LOGGER.info("List of [%s] artifacts to promote: %s" % (artifact_type, artifacts_to_promote))
    if len(artifacts_to_promote) == 0:
        LOGGER.warning("No artifacts to promote")
        raise Exception("No artifacts to promote")

    # promote artifacts
    for i in artifacts_to_promote:
        src_path="%s/%s/%s" % (src, comp_full_name, i)
        dest_path="%s/%s/%s" % (dest, comp_full_name, i)

        LOGGER.debug("Promoting [%s] to [%s]" % (src_path, dest_path))
        try:
            LOGGER.info("src path: %s" % src_path)
            LOGGER.info("dest path: %s" % dest_path)
            # artifact_info = art.artifacts.info(f"{src_path}")
            # LOGGER.info(artifact_info)
            artifact = art.artifacts.copy(f"{src_path}", f"{dest_path}", dryrun=dry_run)
            LOGGER.info("Promoted [%s] to [%s]" % (src_path, dest_path))
        except Exception as e:
            LOGGER.error("something went wrong \n%s" % e)
            raise e
        
    return artifact


def main():
    # Set CWD for command execution to repository root, assuming that's `../`
    os.chdir(Path(__file__).parent.parent)
    LOGGER.info('\n\nRunning from %s' % os.getcwd())

    parser = argparse.ArgumentParser(description='Manage Promotion of Artifacts, Download Scripts, and Updating inputs.cue')
    action_sp = parser.add_subparsers(dest='action')
    
    # Add generate sub command
    generate_p = action_sp.add_parser('generate', help='Generate assets based on templates')
    
    # add inputs and download_script sub commands
    generate_sp = generate_p.add_subparsers(dest='action_generate')
    generate_inputs_p = generate_sp.add_parser('inputs', help="Generate inputs.cue")
    generate_download_script_p = generate_sp.add_parser('download-script', help="Generate Download Script")

    promote_p = action_sp.add_parser('promote', help="Promote assets")
    promote_sp = promote_p.add_subparsers(dest='action_promote')
    # Components that can be promoted by this script
    for i in ['audits', 'catalog', 'cli', 'control', 'control-api', 'dashboard', 'proxy']:
        promote_sp.add_parser(i, help="Promote %s" % i)

    # arguments to add to all
    for i in [generate_inputs_p, generate_download_script_p, promote_p]:
        # used by both generate and promote
        i.add_argument(
            '--src-generic', 
            dest="src_generic",
            type=str,
            default= 'ci-staging-generic',
            help="Source of Generic Artifact"
        )
        i.add_argument(
            '--dest-generic',
            dest="dest_generic",
            type=str,
            default='generic',
            help="Destination of Generic Artifact"
        )
        i.add_argument(
            '--src-oci',
            dest="src_oci",
            type=str,
            default='ci-staging-oci',
            help="Source of OCI Artifact"
        )
        i.add_argument(
            '--dest-oci',
            dest="dest_oci",
            type=str,
            default='oci',
            help="Destination of OCIArtifact"
        )
        i.add_argument(
                '--git-tag', 
                dest="git_tag",
                type=str,    
                default='None',
                help="Git tag for release download script generated"
            )
    # used by only promotion
    promote_p.add_argument(
        '--artifactory-url', 
        dest="artifactory_url",
        type=str,    
        default='greymatter.jfrog.io',
        help="Artifactory url"
    )
    promote_p.add_argument(
        '--artifactory-user', 
        dest="artifactory_user",
        type=str,    
        default='None',
        help="Aritfactory user name"
    )
    promote_p.add_argument(
        '--artifactory-password', 
        dest="artifactory_password",
        type=str,    
        default='None',
        help="Artifactory Password"
    )
    promote_p.add_argument(
        '--dry-run',
        dest="dry_run",
        type=bool,
        default=True,
        help="Run promotion in with dryrun flags on all jfrog commands"
    )
    
    args = parser.parse_args()
    configs=pc.Config(args)

    component_version_dict, component_image_dict=create_component_version_dict()
    
    if configs.git_tag == None:
        component_version_dict['core']='latest'
    else:
        component_version_dict["core"]="%s" % configs.git_tag

    match(args.action):
        case 'generate':
            match(args.action_generate):
                case 'inputs':
                    try:
                        generate_new_input_cue(configs.src_oci, configs.dest_oci)
                    except Exception as e:
                        LOGGER.error("Error generating updated inputs.cue: %s" % e)
                        exit(1)
                case 'download-script':
                    try:
                        generate_download_script(component_version_dict)
                    except Exception as e:
                        LOGGER.error("Error generating download script: %s" % e)
                        exit(1)

        case 'promote':
            component=args.action_promote
            if component != "none":
                # login to artifactory
                try:
                    af_client = Artifactory(url=configs.artifactory_url, auth=(configs.artifactory_user,configs.artifactory_password), api_version=1)
                    
                    component_version=component_version_dict[component]

                    LOGGER.info("DRY RUN is currently set to %s" % configs.dry_run)
                    promote("generic", af_client, component, component_version, configs.src_generic, configs.dest_generic, configs.dry_run)
                    promote("oci" ,af_client, component, component_version, configs.src_oci, configs.dest_oci, configs.dry_run)
                except Exception as e:
                    LOGGER.error("Error promoting %s.\nException:\n%s" % (component, e))
                    # TODO: create an promotion cleanup function to revert changes if exception is found
                    exit(1)


if __name__ == "__main__":
    main()
