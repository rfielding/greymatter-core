package greymatter

import (
	rbacv1 "k8s.io/api/rbac/v1"
)

openshift_spire_scc: [
	// SCC https://spiffe.io/docs/latest/deploying/spire_agent/#security-context-constraints
	{
		allowHostDirVolumePlugin: true
		allowHostIPC:             true
		allowHostNetwork:         true
		allowHostPID:             true
		allowHostPorts:           true
		allowPrivilegeEscalation: true
		allowPrivilegedContainer: false
		allowedCapabilities:      null
		allowedUnsafeSysctls:     null
		apiVersion:               "security.openshift.io/v1"
		defaultAddCapabilities:   null
		fsGroup: type: "MustRunAs"
		groups: []
		kind: "SecurityContextConstraints"
		metadata: {
			annotations: {
				"include.release.openshift.io/self-managed-high-availability": "true"
				"kubernetes.io/description":                                   "Customized policy for Spire to enable host level access."
				"release.openshift.io/create-only":                            "true"
			}
			name: "spire"
		}
		priority:               null
		readOnlyRootFilesystem: false
		requiredDropCapabilities: [ "KILL", "MKNOD", "SETUID", "SETGID"]
		runAsUser: type:          "RunAsAny"
		seLinuxContext: type:     "MustRunAs"
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
			name: "\(config.operator_namespace)-system:openshift:scc:spire"
		}
		rules: [{
			apiGroups: ["security.openshift.io"]
			resourceNames: ["spire"]
			resources: ["securitycontextconstraints"]
			verbs: ["use"]
		}]
	},
	rbacv1.#RoleBinding & {
		apiVersion: "rbac.authorization.k8s.io/v1"
		kind:       "ClusterRoleBinding"
		metadata: {
			name:      "system:openshift:scc:spire:agent"
			namespace: defaults.spire.namespace
		}
		roleRef: {
			apiGroup: "rbac.authorization.k8s.io"
			kind:     "ClusterRole"
			name:     "\(config.operator_namespace)-system:openshift:scc:spire"
		}
		subjects: [{
			kind:      "ServiceAccount"
			name:      "agent"
			namespace: defaults.spire.namespace
		}]
	},
]


openshift_spire: [
	// RoleBindings for greymatter services so they can access their agent.sock
	rbacv1.#RoleBinding & {// controlensemble
		apiVersion: "rbac.authorization.k8s.io/v1"
		kind:       "RoleBinding"
		metadata: {
			name:      "system:openshift:scc:spire:controlensemble"
			namespace: mesh.spec.install_namespace
		}
		roleRef: {
			apiGroup: "rbac.authorization.k8s.io"
			kind:     "ClusterRole"
			name:     "\(config.operator_namespace)-system:openshift:scc:spire"
		}
		subjects: [{
			kind:      "ServiceAccount"
			name:      "controlensemble"
			namespace: mesh.spec.install_namespace
		}]
	},
	rbacv1.#RoleBinding & {// prometheus
		apiVersion: "rbac.authorization.k8s.io/v1"
		kind:       "RoleBinding"
		metadata: {
			name:      "system:openshift:scc:spire:prometheus"
			namespace: mesh.spec.install_namespace
		}
		roleRef: {
			apiGroup: "rbac.authorization.k8s.io"
			kind:     "ClusterRole"
			name:     "\(config.operator_namespace)-system:openshift:scc:spire"
		}
		subjects: [{
			kind:      "ServiceAccount"
			name:      "prometheus"
			namespace: mesh.spec.install_namespace
		}]
	},
	rbacv1.#RoleBinding & {// default service account (used by sidecars without a service account)
		apiVersion: "rbac.authorization.k8s.io/v1"
		kind:       "RoleBinding"
		metadata: {
			name:      "system:openshift:scc:spire:default"
			namespace: mesh.spec.install_namespace
		}
		roleRef: {
			apiGroup: "rbac.authorization.k8s.io"
			kind:     "ClusterRole"
			name:     "\(config.operator_namespace)-system:openshift:scc:spire"
		}
		subjects: [{
			kind:      "ServiceAccount"
			name:      "default"
			namespace: mesh.spec.install_namespace
		}]
	},
]
