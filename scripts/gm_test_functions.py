#!/usr/bin/env python3

import yaml
import json
import argparse
import subprocess
import constant
import copy
import logging

from jsonschema import validate

LOGGER = logging.getLogger(__name__)

class myMesh:
    cluster_dict=dict()
    listener_dict=dict()
    domain_dict=dict()
    proxy_dict=dict()
    route_dict=dict()
    catalog_entries_dict=dict()
    zone_dict=dict()

    def total_objects(self):
        return(len(self.catalog_entries_dict) + len(self.cluster_dict) + len(self.listener_dict) + len(self.domain_dict) + len(self.proxy_dict) + len(self.route_dict))

    def info(self):
        print("catalog_entry dict size: %s" % len(self.catalog_entries_dict))
        print("cluster dict size: %s" % len(self.cluster_dict))
        print("listener dict size: %s" % len(self.listener_dict))
        print("domain dict size: %s" % len(self.domain_dict))
        print("proxy dict size: %s" % len(self.proxy_dict))
        print("route dict size: %s" % len(self.route_dict))

# checks if an object is of the object_type
def is_x(object, object_schema):
    test_schema=object_schema
    try:
        validate(instance=object, schema=test_schema)
    except:
        return False
    return True

def cue_eval(tag_dict):
    eval_cmd="cue eval -c ./gm/outputs -e mesh_configs --out=json"
    for i in tag_dict:
        print(i)
        eval_cmd="%s -t %s=%s" % (eval_cmd, i, tag_dict[i])
    r=""
    print(eval_cmd)
    try:
        r=getProcessOutput(eval_cmd)
    except subprocess.CalledProcessError as e:
        print("could not render json from cue eval string provided")
        print(e)
        return e
    return r

def getProcessOutput(cmd):
    process = subprocess.Popen(
        cmd,
        shell=True,
        stdout=subprocess.PIPE)
    process.wait()
    data, err = process.communicate()
    if process.returncode == 0:
        return data.decode('utf-8')
    else:
        print("Error:", err)
    return ""

def build_mesh_from_cue(my_cue_json):
    mesh = myMesh()
    raw_objects=[]
    try:
        print("---- Loading json ----")
        load = yaml.safe_load_all(my_cue_json)

        for i in load:
            raw_objects.append(i)
        print("---- Done Loading json ----")
    except yaml.YAMLError as exc:
        print(exc)
    
    print("Input objects %s" % len(raw_objects[0]))
    # print(type(raw_objects))
    for i in raw_objects[0]:
        if is_x(i, constant.CATALOG_ENTRY_SCHEMA): mesh.catalog_entries_dict["%s" % i["service_id"]] = i
        if is_x(i, constant.CLUSTER_SCHEMA): mesh.cluster_dict["%s" % i["cluster_key"]] = i
        if is_x(i, constant.LISTENER_SCHEMA): mesh.listener_dict["%s" % i["listener_key"]] = i
        if is_x(i, constant.DOMAIN_SCHEMA): mesh.domain_dict["%s" % i["domain_key"]] = i
        if is_x(i, constant.PROXY_SCHEMA): mesh.proxy_dict["%s" % i["proxy_key"]] = i
        if is_x(i, constant.ROUTE_SCHEMA): mesh.route_dict["%s" % i["route_key"]] = i

    check=mesh.total_objects
    print("Sum of segregated objects %s" % check)
    if len(raw_objects[0]) != check:
        print("WE GOT A PROBLEM DOWN HERE")
    return mesh

def pretty_print(x):
    print(json.dumps(x, indent=2))


def test_ssl_plaintext_edge_but_edge_require_client_certs_true():
    # this should not enable require_client_certs (falls back to no tls)
    test_tag_dict={
        "edge_enable_tls": "false",
        "edge_require_client_certs": "false",
        "internal_enable_tls": "false",
        "spire": "false",
    }

    # evaluate cue and extract mesh configs
    r = cue_eval(test_tag_dict)
    m1=build_mesh_from_cue(r)
    m1.total_objects
    
    # assertions
    # ALL DOMAINS SHOULD NOT HAVE SSL CONFIG
    test_schema= copy.deepcopy(constant.DOMAIN_SCHEMA)
    test_schema.update({"required": ["ssl_config"]})
    for i in m1.domain_dict:
            assert is_x(m1.domain_dict.get(i),test_schema) == False
    
    # ALL CLUSTERS SHOULD HAVE NO SSL ENABLED 
    test_schema2=copy.deepcopy(constant.CLUSTER_SCHEMA)
    test_schema2.update({"required": ["ssl_config"]})
    for i in m1.cluster_dict:
        LOGGER.info(i)
        assert is_x(m1.cluster_dict.get(i),test_schema) == False


def test_ssl_spire_only_true():
    # define tag dictionary
    test_tag_dict={
        "edge_enable_tls": "false",
        "edge_require_client_certs": "false",
        "internal_enable_tls": "false",
        "spire": "true",
    }

    # evaluate cue and extract mesh configs
    r = cue_eval(test_tag_dict)
    m1=build_mesh_from_cue(r)
    m1.total_objects
    
    # assertions
    for i in (i for i in m1.cluster_dict if i != "edge"):
        # All clusters except edge will get a spire secret block
        test_schema=copy.deepcopy(constant.CLUSTER_SCHEMA)
        test_schema.update({"required": ["secret"]})

        has_instance=False
        if len(m1.cluster_dict.get(i)["instances"]) > 0:
            has_instance=is_x(m1.cluster_dict.get(i)["instances"][0], constant.HOST_PORT_SCHEMA)
        
        LOGGER.info(m1.cluster_dict.get(i))
        if has_instance:
            # local
            # assert all non edge clusters (with instances) do not have spire secrets
            LOGGER.info(is_x(m1.cluster_dict.get(i),test_schema))
            assert is_x(m1.cluster_dict.get(i),test_schema) == False
        else:
            # inter sidecar
            LOGGER.info(is_x(m1.cluster_dict.get(i),test_schema))
            assert is_x(m1.cluster_dict.get(i),test_schema) == True

    # no cluster should have a tls block
    test_schema2= copy.deepcopy(constant.CLUSTER_SCHEMA)
    test_schema2.update({"required": ["ssl_config"]})
    for i in m1.cluster_dict:
        LOGGER.info(m1.cluster_dict.get(i))
        assert is_x(m1.cluster_dict.get(i),test_schema2) == False

    # no domains should have a tls block on them
    test_schema3= copy.deepcopy(constant.DOMAIN_SCHEMA)
    test_schema3.update({"required": ["ssl_config"]})
    for i in m1.domain_dict:
        assert is_x(m1.domain_dict.get(i),test_schema3) == False


def test_ssl_internal_tls_only():
    # should fail to evaluate
    test_tag_dict={
        "edge_enable_tls": "false",
        "edge_require_client_certs": "false",
        "internal_enable_tls": "true",
        "spire": "false",
    }
    # TODO: WELL THIS IS A HACK LOL.  exception should be from sub proccess (really cue eval of _security_spec schema will not allow this)
    foundException=False
    try:
        # evaluate cue and extract mesh configs
        r = cue_eval(test_tag_dict)
        m1=build_mesh_from_cue(r)
    except:
        foundException=True
    # assertions
    assert foundException == True


def test_ssl_edge_tls_only():
    test_tag_dict={
        "edge_enable_tls": "true",
        "edge_require_client_certs": "false",
        "internal_enable_tls": "false",
        "spire": "false",
    }

    # evaluate cue and extract mesh configs
    r = cue_eval(test_tag_dict)
    m1=build_mesh_from_cue(r)

    # assertions
    # only edge domain should have ssl block
    # edge should not require_client_certs
    test_schema= copy.deepcopy(constant.DOMAIN_SCHEMA)
    test_schema.update({"required": ["ssl_config"]})
    for i in m1.domain_dict:
        if i == "edge":
            # edge domain should have an ssl_config
            assert is_x(m1.domain_dict.get(i),test_schema) == True
            assert m1.domain_dict.get(i)["ssl_config"]["require_client_certs"] == False
        else:
            # all non edge should be false
            assert is_x(m1.domain_dict.get(i),test_schema) == False

    # no clusters should have ssl_config block
    test_schema2= copy.deepcopy(constant.CLUSTER_SCHEMA)
    test_schema2.update({"required": ["ssl_config"]})
    for i in m1.cluster_dict:
        LOGGER.info(m1.cluster_dict.get(i))
        assert is_x(m1.cluster_dict.get(i),test_schema2) == False
    
    # no clusters should have secret block
    test_schema3= copy.deepcopy(constant.CLUSTER_SCHEMA)
    test_schema3.update({"required": ["secret"]})
    for i in m1.cluster_dict:
        LOGGER.info(m1.cluster_dict.get(i))
        assert is_x(m1.cluster_dict.get(i),test_schema3) == False


def test_ssl_edge_mtls_only():
    test_tag_dict={
        "edge_enable_tls": "true",
        "edge_require_client_certs": "true",
        "internal_enable_tls": "false",
        "spire": "false",
    }

    # evaluate cue and extract mesh configs
    r = cue_eval(test_tag_dict)
    m1=build_mesh_from_cue(r)

    # assertions
    # only edge domain should have ssl block
    # edge should not require_client_certs
    test_schema= copy.deepcopy(constant.DOMAIN_SCHEMA)
    test_schema.update({"required": ["ssl_config"]})
    for i in m1.domain_dict:
        if i == "edge":
            # edge domain should have an ssl_config
            assert is_x(m1.domain_dict.get(i),test_schema) == True
            assert m1.domain_dict.get(i)["ssl_config"]["require_client_certs"] == True
        else:
            # all non edge should be false
            assert is_x(m1.domain_dict.get(i),test_schema) == False

    # no clusters should have ssl_config block
    test_schema2= copy.deepcopy(constant.CLUSTER_SCHEMA)
    test_schema2.update({"required": ["ssl_config"]})
    for i in m1.cluster_dict:
        LOGGER.info(m1.cluster_dict.get(i))
        assert is_x(m1.cluster_dict.get(i),test_schema2) == False
    
    # no clusters should have secret block
    test_schema3= copy.deepcopy(constant.CLUSTER_SCHEMA)
    test_schema3.update({"required": ["secret"]})
    for i in m1.cluster_dict:
        LOGGER.info(m1.cluster_dict.get(i))
        assert is_x(m1.cluster_dict.get(i),test_schema3) == False


def test_ssl_edge_and_internal_tls_true():
    test_tag_dict={
        "edge_enable_tls": "true",
        "edge_require_client_certs": "false",
        "internal_enable_tls": "true",
        "spire": "false",
    }

    # evaluate cue and extract mesh configs
    r = cue_eval(test_tag_dict)
    m1=build_mesh_from_cue(r)
    m1.total_objects
    
    # assertions
    # ALL DOMAINS SHOULD HAVE SSL CONFIG
    test_schema= copy.deepcopy(constant.DOMAIN_SCHEMA)
    test_schema.update({"required": ["ssl_config"]})
    for i in m1.domain_dict:
            assert is_x(m1.domain_dict.get(i),test_schema) == True
    
    # ALL CLUSTERS THAT USE SERVICE DISCOVERY (no instances defined) SHOULD HAVE TLS ENABLED (except edge)
    test_schema2=copy.deepcopy(constant.CLUSTER_SCHEMA)
    test_schema2.update({"required": ["ssl_config"]})
    for i in (i for i in m1.cluster_dict if i != "edge"):
        LOGGER.info(i)
    for i in (i for i in m1.cluster_dict if i != "edge"):
        LOGGER.info(m1.cluster_dict.get(i))
        if len(m1.cluster_dict.get(i)["instances"]) == 0:
            assert is_x(m1.cluster_dict.get(i),test_schema2) == True
        # observables_egress_to_elasticsearch is hardcoded to retuire_tls in gm/outputs/observables.cue
        elif m1.cluster_dict.get(i)["cluster_key"] == "observables_egress_to_elasticsearch":
            assert is_x(m1.cluster_dict.get(i),test_schema2) == True
        else:
            assert is_x(m1.cluster_dict.get(i),test_schema2) == False


def test_ssl_plaintext_edge_but_edge_require_client_certs_true():
    # this should not enable require_client_certs (falls back to no tls)
    test_tag_dict={
        "edge_enable_tls": "false",
        "edge_require_client_certs": "true",
        "internal_enable_tls": "false",
        "spire": "false",
    }

    # evaluate cue and extract mesh configs
    r = cue_eval(test_tag_dict)
    m1=build_mesh_from_cue(r)
    m1.total_objects
    
    # assertions
    # ALL DOMAINS SHOULD NOT HAVE SSL CONFIG
    test_schema= copy.deepcopy(constant.DOMAIN_SCHEMA)
    test_schema.update({"required": ["ssl_config"]})
    for i in m1.domain_dict:
            LOGGER.info(m1.domain_dict.get(i))
            assert is_x(m1.domain_dict.get(i),test_schema) == False
    
    # ALL CLUSTERS SHOULD HAVE NO SSL ENABLED 
    test_schema2=copy.deepcopy(constant.CLUSTER_SCHEMA)
    test_schema2.update({"required": ["ssl_config"]})
    for i in m1.cluster_dict:
        LOGGER.info(m1.cluster_dict.get(i))
        assert is_x(m1.cluster_dict.get(i),test_schema) == False


def test_ssl_edge_and_spire_tls_true():
    test_tag_dict={
        "edge_enable_tls": "true",
        "edge_require_client_certs": "false",
        "internal_enable_tls": "false",
        "spire": "true",
    }

    # evaluate cue and extract mesh configs
    r = cue_eval(test_tag_dict)
    m1=build_mesh_from_cue(r)
    m1.total_objects
    # assertions

    # all clusters should have spire secret block
    for i in (i for i in m1.cluster_dict if i != "edge"):
        # All clusters except edge will get a spire secret block
        test_schema=copy.deepcopy(constant.CLUSTER_SCHEMA)
        test_schema.update({"required": ["secret"]})

        has_instance=False
        if len(m1.cluster_dict.get(i)["instances"]) > 0:
            has_instance=is_x(m1.cluster_dict.get(i)["instances"][0], constant.HOST_PORT_SCHEMA)
        LOGGER.info(m1.cluster_dict.get(i))
        if has_instance:
            # local
            # assert all non edge clusters (with instances) do not have spire secrets
            assert is_x(m1.cluster_dict.get(i),test_schema) == False
        else:
            # inter sidecar
            assert is_x(m1.cluster_dict.get(i),test_schema) == True

    # no clusters should have ssl config block
    test_schema2= copy.deepcopy(constant.CLUSTER_SCHEMA)
    test_schema2.update({"required": ["ssl_config"]})
    for i in m1.cluster_dict:
        LOGGER.info(m1.cluster_dict.get(i))
        assert is_x(m1.cluster_dict.get(i),test_schema2) == False

    # no domains should have ssl config block (except edge) for 1 way tls
    test_schema3= copy.deepcopy(constant.DOMAIN_SCHEMA)
    test_schema3.update({"required": ["ssl_config"]})
    for i in m1.domain_dict:
        if i == "edge":
            assert is_x(m1.domain_dict.get(i),test_schema3) == True
        else:
            assert is_x(m1.domain_dict.get(i),test_schema3) == False


def test_ssl_spire_takes_precedence_over_internal_tls():
    # define tag dictionary
    test_tag_dict={
        "edge_enable_tls": "false",
        "edge_require_client_certs": "false",
        "internal_enable_tls": "true",
        "spire": "true",
    }

    # evaluate cue and extract mesh configs
    r = cue_eval(test_tag_dict)
    m1=build_mesh_from_cue(r)
    m1.total_objects
    
    # assertions
    for i in (i for i in m1.cluster_dict if i != "edge"):
        # All clusters except edge will get a spire secret block
        test_schema=copy.deepcopy(constant.CLUSTER_SCHEMA)
        test_schema.update({"required": ["secret"]})

        has_instance=False
        if len(m1.cluster_dict.get(i)["instances"]) > 0:
            has_instance=is_x(m1.cluster_dict.get(i)["instances"][0], constant.HOST_PORT_SCHEMA)

        LOGGER.info(m1.cluster_dict.get(i))
        if has_instance:
            # local
            # assert all non edge clusters (with instances) do not have spire secrets
            assert is_x(m1.cluster_dict.get(i),test_schema) == False
        else:
            # inter sidecar
            assert is_x(m1.cluster_dict.get(i),test_schema) == True

    # no cluster should have a tls block
    test_schema2= copy.deepcopy(constant.CLUSTER_SCHEMA)
    test_schema2.update({"required": ["ssl_config"]})
    for i in m1.cluster_dict:
        LOGGER.info(m1.cluster_dict.get(i))
        assert is_x(m1.cluster_dict.get(i),test_schema2) == False

    # no domains should have a tls block on them
    test_schema3= copy.deepcopy(constant.DOMAIN_SCHEMA)
    test_schema3.update({"required": ["ssl_config"]})
    for i in m1.domain_dict:
        LOGGER.info(m1.domain_dict.get(i))
        assert is_x(m1.domain_dict.get(i),test_schema3) == False

def print_dict_keys(a_dict):
    for i in a_dict:
        print(i)
