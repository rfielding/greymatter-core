#!/usr/bin/env python3

import yaml
import argparse
import os

# resource_order to apply
# most from helm's implementation
# SecurityContextConstraints best guess location
resource_order=("Namespace", "NetworkPolicy", "ResourceQuota", "LimitRange", "PodSecurityPolicy", "PodDisruptionBudget", "ServiceAccount", "Secret", "SecretList", "ConfigMap", "StorageClass", "PersistentVolume", "PersistentVolumeClaim", "CustomResourceDefinition","SecurityContextConstraints", "ClusterRole", "ClusterRoleList", "ClusterRoleBinding", "ClusterRoleBindingList", "Role", "RoleList", "RoleBinding", "RoleBindingList", "Service", "DaemonSet", "Pod", "ReplicationController", "ReplicaSet", "Deployment", "HorizontalPodAutoscaler", "StatefulSet", "Job", "CronJob", "IngressClass", "Ingress", "APIService")

# list of dicts
objects=[]
with open("transform-manifest/manifest.yaml", "r") as file:
    try:
        print("---- Loading yaml ----")
        resources = yaml.safe_load_all(file)
        type(resources)

        for i in resources:
            print(i['kind'])
            objects.append(i)

    except yaml.YAMLError as exc:
        print(exc)
    print("---- Done Load ----")


processed_objects=0
for r in resource_order:
    print(f'> Resource: {r}')
    # print("")

    for i in objects:
        
        kind=i['kind']
        name=i['metadata']['name']
        
        # print(f'Looking at kind: [{kind}] , name: [{name}]')
        if kind == r:
            print("    " + name)

            with open("transform-manifest/manifest-reorder.yaml", 'a') as file:
                yaml.safe_dump(i,file)
                if processed_objects != len(objects)-1:
                    file.write("---\n")
            
                processed_objects = processed_objects + 1
    
print("")

