// k8s manifests for Observables App

package greymatter

import (
	appsv1 "k8s.io/api/apps/v1"
	"strings"
)

let Name = "observables"

observables: [
	appsv1.#Deployment & {
		apiVersion: "apps/v1"
		kind:       "Deployment"
		metadata: {
			name:      Name
			namespace: mesh.spec.install_namespace
		}
		spec: {
			selector: {
				matchLabels: {"greymatter.io/cluster": Name}
			}
			template: {
				metadata: {
					labels: {
						"greymatter.io/cluster":  Name
						"greymatter.io/workload": "\(config.operator_namespace).\(mesh.metadata.name).\(Name)"
						for i in defaults.additional_labels.all_pods {
							"\(strings.Split(i, ":")[0])": "\(strings.Split(i, ":")[1])",
						}
						if len(defaults.additional_labels.external_spire_label) > 0{
							"\(defaults.additional_labels.external_spire_label)": "\(config.operator_namespace).\(mesh.metadata.name).\(Name)"
						}
					}
				}
				spec: #spire_permission_requests & {
					containers: [
						#sidecar_container_block & {_Name: Name},
						{
							name:            Name
							image:           defaults.images.observables
							imagePullPolicy: defaults.image_pull_policy
							ports: [{
								containerPort: 5000
							}]
							env: [{
								name:  "BASE_PATH"
								value: "/services/audits"
							}, {
								name:  "ES_INDEX"
								value: defaults.audits.query_index
							}, {
								name:  "ES_EDGE_TOPIC"
								value: defaults.edge.key
							}, {
								name:  "TARGET_PRODUCT"
								value: "gm"
							}, {
								name:  "ES_USER"
								value: defaults.audits.elasticsearch_username
							}, {
								name: "ES_PASSWORD"
								valueFrom: {
									secretKeyRef: {
										name: defaults.audits.elasticsearch_password_secret
										key:  "password"
									}
								}
							}, {
								// Required for upstream requests to Elasticsearch
								// https://app.shortcut.com/grey-matter/story/31682/audit-app-es-egress-config-sets-host-header-unsupported-in-envoy-1-24-0
								name:  "ES_HOST"
								value: defaults.audits.elasticsearch_host
							}]
							resources: {
								limits: {
									cpu:    "20m"
									memory: "2Gi"
								}
								requests: {
									cpu:    "10m"
									memory: "19Mi"
								}
							}
						},
					]
					volumes: #sidecar_volumes
					imagePullSecrets: [{
						name: "gm-docker-secret"
					}]
				}
			}
		}
	},
]
