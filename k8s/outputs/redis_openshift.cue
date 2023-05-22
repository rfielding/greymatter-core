// K8s manifests necessary for openshift

package greymatter

import (
	rbacv1 "k8s.io/api/rbac/v1"
)

openshift_redis_scc_bindings: [

]

openshift_redis_scc: [
	{
		apiVersion: "security.openshift.io/v1"
		kind:       "SecurityContextConstraints"
		metadata: {
			annotations: {
				"include.release.openshift.io/self-managed-high-availability": "true"
				"kubernetes.io/description":                                   "Customized policy for Redis to enable fsGroup volumes."
				"release.openshift.io/create-only":                            "true"
			}
			name: "redis-scc"
		}
		allowHostDirVolumePlugin: true
		allowHostIPC:             false
		allowHostNetwork:         false
		allowHostPID:             true
		allowHostPorts:           false
		allowPrivilegeEscalation: false
		allowPrivilegedContainer: false
		allowedCapabilities:      null
		allowedUnsafeSysctls:     null
		defaultAddCapabilities:   null
		fsGroup: type: "RunAsAny"
		groups: []
		priority:               null
		readOnlyRootFilesystem: false
		requiredDropCapabilities: [ "KILL", "MKNOD", "SETUID", "SETGID"]
		runAsUser: type:      "RunAsAny"
		seLinuxContext: type: "MustRunAs"
		seccompProfiles: [ "runtime/default"]
		supplementalGroups: type: "RunAsAny"
		users: []
		volumes: [
			"hostPath",
			"configMap",
			"downwardAPI",
			"emptyDir",
			"persistentVolumeClaim",
			"projected",
			"secret",
		]
	},
	rbacv1.#ClusterRole & {
		apiVersion: "rbac.authorization.k8s.io/v1"
		kind:       "ClusterRole"
		metadata: {
			annotations: {
				"include.release.openshift.io/self-managed-high-availability": "true"
				"rbac.authorization.kubernetes.io/autoupdate":                 "true"
			}
			name: "\(config.operator_namespace)-redis-scc"
		}
		rules: [{
			apiGroups: ["security.openshift.io"]
			resourceNames: ["redis-scc"]
			resources: ["securitycontextconstraints"]
			verbs: ["use"]
		}]
	},
	rbacv1.#RoleBinding & {
		apiVersion: "rbac.authorization.k8s.io/v1"
		kind:       "RoleBinding"
		metadata: {
			name:      "\(config.operator_namespace)-redis-scc"
			namespace: mesh.spec.install_namespace
		}
		roleRef: {
			apiGroup: "rbac.authorization.k8s.io"
			kind:     "ClusterRole"
			name:     "\(config.operator_namespace)-redis-scc"
		}
		subjects: [{
			kind:      "ServiceAccount"
			name:      defaults.redis_cluster_name
			namespace: mesh.spec.install_namespace
		}]
	},
]
