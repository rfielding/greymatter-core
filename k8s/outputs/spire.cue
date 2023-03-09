// k8s manifests for Spire

package greymatter

import (
	appsv1 "k8s.io/api/apps/v1"
	corev1 "k8s.io/api/core/v1"
	rbacv1 "k8s.io/api/rbac/v1"
)

spire_namespace: [
	corev1.#Namespace & {
		// Starting with this Namespace, these manifests should only apply if we want Spire
		apiVersion: "v1"
		kind:       "Namespace"
		metadata: {
			name: defaults.spire.namespace
			labels: name: "spire"
		}
	},
]

spire_server: [
	corev1.#Service & {
		apiVersion: "v1"
		kind:       "Service"
		metadata: {
			name:      "server"
			namespace: defaults.spire.namespace
		}
		spec: {
			type: "NodePort"
			selector: app: "server"
			ports: [{
				name:       "server"
				protocol:   "TCP"
				port:       8443
				targetPort: 8443
			}]
		}
	},
	appsv1.#StatefulSet & {
		apiVersion: "apps/v1"
		kind:       "StatefulSet"
		metadata: {
			name:      "server"
			namespace: defaults.spire.namespace
			labels: app: "server"
		}
		spec: {
			selector: matchLabels: app: "server"
			serviceName: "server"
			template: {
				metadata: {
					name:      "server"
					namespace: defaults.spire.namespace
					labels: app: "server"
				}
				spec: {
					containers: [{
						name:            "server"
						image:           "gcr.io/spiffe-io/spire-server:1.5.4"
						imagePullPolicy: "IfNotPresent"
						args: [
							"-config",
							"/run/spire/config/server.conf",
						]
						ports: [{
							containerPort: 8443
							name:          "server"
							protocol:      "TCP"
						}]
						livenessProbe: {
							exec: command: [
								"/opt/spire/bin/spire-server",
								"healthcheck",
								"-socketPath=\(defaults.spire.socket_mount_path)/registration.sock",
							]
							failureThreshold:    2
							initialDelaySeconds: 15
							periodSeconds:       60
							timeoutSeconds:      3
						}
						volumeMounts: [{
							name:      "server-socket"
							mountPath: defaults.spire.socket_mount_path
						}, {
							name:      "server-config"
							mountPath: "/run/spire/config"
							readOnly:  true
						}, {
							name:      defaults.spire.ca_secret_name
							mountPath: "/run/spire/ca"
							readOnly:  true
						}, {
							name:      "server-data" // Mounted from PVC
							mountPath: "/run/spire/data"
						}]
						resources: spire_server_resources
					}, {
						name:            "registrar"
						image:           "gcr.io/spiffe-io/k8s-workload-registrar:1.5.4"
						imagePullPolicy: "IfNotPresent"
						args: [
							"-config",
							"/run/spire/config/registrar.conf",
						]
						ports: [{
							containerPort: 8444
							name:          "registrar"
							protocol:      "TCP"
						}]
						volumeMounts: [{
							name:      "server-config"
							mountPath: "/run/spire/config"
							readOnly:  true
						}, {
							name:      "server-socket"
							mountPath: defaults.spire.socket_mount_path
						}]
						resources: spire_server_resources
					}]
					volumes: [{
						name: "server-socket"
						emptyDir: medium: "Memory"
					}, {
						name: "server-config"
						configMap: {
							name:        "server-config"
							defaultMode: 420
						}
					}, {
						name: defaults.spire.ca_secret_name
						secret: {
							secretName:  defaults.spire.ca_secret_name
							defaultMode: 420
						}
					}]
					serviceAccountName:    "server"
					shareProcessNamespace: true
				}
			}
			volumeClaimTemplates: [{
				apiVersion: "v1"
				kind:       "PersistentVolumeClaim"
				metadata: {
					name:      "server-data"
					namespace: defaults.spire.namespace
				}
				spec: {
					accessModes: [
						"ReadWriteOnce",
					]
					resources: requests: storage: "1Gi"
					volumeMode: "Filesystem"
				}
			}]
		}
	},
	corev1.#ServiceAccount & {
		apiVersion: "v1"
		kind:       "ServiceAccount"
		metadata: {
			name:      "server"
			namespace: defaults.spire.namespace
		}
	},
	rbacv1.#Role & {
		apiVersion: "rbac.authorization.k8s.io/v1"
		kind:       "Role"
		metadata: {
			name:      "server"
			namespace: defaults.spire.namespace
		}
		rules: [
			{
				apiGroups: [""]
				resources: ["configmaps"]
				verbs: ["create", "list", "get", "update", "patch"]
			},
			{
				apiGroups: [""]
				resources: ["events"]
				verbs: ["create"]
			},
		]
	},
	rbacv1.#ClusterRole & {
		apiVersion: "rbac.authorization.k8s.io/v1"
		kind:       "ClusterRole"
		metadata: name: "spire-server"
		rules: [
			{
				apiGroups: [""]
				resources: ["pods", "nodes", "endpoints"]
				verbs: ["get", "list", "watch"]
			},
			{
				apiGroups: [ "authentication.k8s.io"]
				resources: [ "tokenreviews"]
				verbs: [ "get", "create"]
			},
		]
	},
	rbacv1.#RoleBinding & {
		apiVersion: "rbac.authorization.k8s.io/v1"
		kind:       "RoleBinding"
		metadata: {
			name:      "server"
			namespace: defaults.spire.namespace
		}
		roleRef: {
			apiGroup: "rbac.authorization.k8s.io"
			kind:     "Role"
			name:     "server"
		}
		subjects: [{
			kind:      "ServiceAccount"
			name:      "server"
			namespace: defaults.spire.namespace
		}]
	},
	rbacv1.#ClusterRoleBinding & {
		apiVersion: "rbac.authorization.k8s.io/v1"
		kind:       "ClusterRoleBinding"
		metadata: name: "spire-server"
		roleRef: {
			apiGroup: "rbac.authorization.k8s.io"
			kind:     "ClusterRole"
			name:     "spire-server"
		}
		subjects: [{
			kind:      "ServiceAccount"
			name:      "server"
			namespace: defaults.spire.namespace
		}]
	},
	corev1.#ConfigMap & {
		apiVersion: "v1"
		kind:       "ConfigMap"
		metadata: {
			name:      "server-config"
			namespace: defaults.spire.namespace
		}
		data: {
			// https://github.com/spiffe/spire/tree/main/support/k8s/k8s-workload-registrar
			// https://github.com/lucianozablocki/spire-tutorials/tree/k8s-registrar-tutorial/k8s/k8s-workload-registrar#configure-reconcile-mode
			"registrar.conf": #"""
        trust_domain = "\#(defaults.spire.trust_domain)"
        server_socket_path = "\#(defaults.spire.socket_mount_path)/registration.sock"
        cluster = "meshes"
        mode = "reconcile"
        pod_label = "greymatter.io/workload"
        metrics_addr = "0"
        controller_name = "k8s-workload-registrar"
        log_level = "debug"
        log_path = "/dev/stdout"
        """#

			// https://spiffe.io/docs/latest/deploying/spire_server/
			"server.conf": #"""
        server {
          bind_address = "0.0.0.0"
          bind_port = "8443"
          ca_subject = {
            country = ["US"],
            organization = ["Grey Matter"],
            common_name = "Mesh",
          }
          data_dir = "/run/spire/data"
          default_svid_ttl = "1h"
          log_file = "/dev/stdout"
          log_level = "DEBUG"
          trust_domain = "\#(defaults.spire.trust_domain)"
          socket_path = "\#(defaults.spire.socket_mount_path)/registration.sock"
        }
        plugins {
          DataStore "sql" {
            plugin_data {
              database_type = "sqlite3"
              connection_string = "/run/spire/data/datastore.sqlite3"
            }
          }
          NodeAttestor "k8s_psat" {
            plugin_data {
              clusters = {
                "meshes" = {
                  service_account_allow_list = ["spire:agent"]
                  audience = ["server"]
                }
              }
            }
          }
          KeyManager "disk" {
            plugin_data {
              keys_path = "/run/spire/data/keys.json"
            }
          }
          Notifier "k8sbundle" {
            plugin_data {
              namespace = "\#(defaults.spire.namespace)"
              config_map = "server-bundle"
            }
          }
          UpstreamAuthority "disk" {
            plugin_data {
              cert_file_path = "/run/spire/ca/intermediate.crt"
              key_file_path = "/run/spire/ca/intermediate.key"
              bundle_file_path = "/run/spire/ca/root.crt"
            }
          }
        }
        """#
		}
	},
	corev1.#ConfigMap & {
		apiVersion: "v1"
		kind:       "ConfigMap"
		metadata: {
			name:      "server-bundle"
			namespace: defaults.spire.namespace
		}
		data: "bundle.crt": ""
	},
]

spire_agent: [

	appsv1.#DaemonSet & {
		apiVersion: "apps/v1"
		kind:       "DaemonSet"
		metadata: {
			name:      "agent"
			namespace: defaults.spire.namespace
			labels: app: "agent"
		}
		spec: {
			selector: matchLabels: app: "agent"
			template: {
				metadata: {
					namespace: defaults.spire.namespace
					labels: app: "agent"
				}
				spec: {
					initContainers: [{
						name:            "init-server"
						image:           "gcr.io/spiffe-io/wait-for-it"
						imagePullPolicy: "IfNotPresent"
						args: [
							"-t",
							"30",
							"server:8443",
						]
						resources: {}
					}]
					containers: [{
						name:            "agent"
						image:           "gcr.io/spiffe-io/spire-agent:1.5.4"
						imagePullPolicy: "IfNotPresent"
						args: [
							"-config",
							"/run/spire/config/agent.conf",
						]
						livenessProbe: {
							exec: command: [
								"/opt/spire/bin/spire-agent",
								"healthcheck",
								"-socketPath",
								"\(defaults.spire.socket_mount_path)/agent.sock",
							]
							failureThreshold:    2
							initialDelaySeconds: 15
							periodSeconds:       60
							timeoutSeconds:      3
						}
						volumeMounts: [{
							name:      "agent-config"
							mountPath: "/run/spire/config"
							readOnly:  true
						}, {
							name:      "agent-socket"
							mountPath: defaults.spire.socket_mount_path
						}, {
							name:      "server-bundle"
							mountPath: "/run/spire/bundle"
							readOnly:  true
						}, {
							name:      "agent-token"
							mountPath: "/run/spire/token"
						}]
						resources: spire_agent_resources
					}]
					volumes: [{
						name: "agent-config"
						configMap: {
							defaultMode: 420
							name:        "agent-config"
						}
					}, {
						name: "agent-socket"
						hostPath: {
							path: defaults.spire.socket_mount_path
							type: "DirectoryOrCreate"
						}
					}, {
						name: "server-bundle"
						configMap: {
							defaultMode: 420
							name:        "server-bundle"
						}
					}, {
						name: "agent-token"
						projected: {
							defaultMode: 420
							sources: [{
								serviceAccountToken: {
									audience:          "server"
									expirationSeconds: 7200
									path:              "agent"
								}
							}]
						}
					}]
					serviceAccountName: "agent"
					dnsPolicy:          "ClusterFirstWithHostNet"
					hostNetwork:        true
					hostPID:            true
				}
			}
		}
	},

	corev1.#ServiceAccount & {
		apiVersion: "v1"
		kind:       "ServiceAccount"
		metadata: {
			name:      "agent"
			namespace: defaults.spire.namespace
		}
	},

	rbacv1.#ClusterRole & {
		apiVersion: "rbac.authorization.k8s.io/v1"
		kind:       "ClusterRole"
		metadata: name: "spire-agent"
		rules: [{
			apiGroups: [
				"",
			]
			resources: [
				"pods",
				"nodes",
				"nodes/proxy",
			]
			verbs: [
				"get",
				"list",
			]
		}]
	},

	rbacv1.#ClusterRoleBinding & {
		apiVersion: "rbac.authorization.k8s.io/v1"
		kind:       "ClusterRoleBinding"
		metadata: name: "spire-agent"
		roleRef: {
			apiGroup: "rbac.authorization.k8s.io"
			kind:     "ClusterRole"
			name:     "spire-agent"
		}
		subjects: [{
			kind:      "ServiceAccount"
			name:      "agent"
			namespace: defaults.spire.namespace
		}]
	},
	corev1.#ConfigMap & {
		apiVersion: "v1"
		kind:       "ConfigMap"
		metadata: {
			name:      "agent-config"
			namespace: defaults.spire.namespace
		}
		data: "agent.conf": #"""
      agent {
        data_dir = "/run/spire"
        log_level = "INFO"
        server_address = "server"
        server_port = "8443"
        socket_path = "\#(defaults.spire.socket_mount_path)/agent.sock"
        trust_bundle_path = "/run/spire/bundle/bundle.crt"
        trust_domain = "\#(defaults.spire.trust_domain)"
      }
      plugins {
        NodeAttestor "k8s_psat" {
          plugin_data {
            cluster = "meshes"
            token_path = "/run/spire/token/agent"
          }
        }
        KeyManager "memory" {
          plugin_data {
          }
        }
        WorkloadAttestor "k8s" {
          plugin_data {
            skip_kubelet_verification = true
          }
        }
      }
      """#
	},
]
