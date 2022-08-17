package greymatter

import (
	corev1 "k8s.io/api/core/v1"
)

// Note that this container block needs to go in `containers`, and refers to a
// spire-socket volume that must be configured separately (see below)
#sidecar_container_block: {
	_Name: string
	_volume_mounts: [...]

	name:  "sidecar"
	image: mesh.spec.images.proxy
	ports: [...corev1.#ContainerPort] | *[
		{
			name:          "proxy"
			containerPort: defaults.ports.default_ingress
		},
		{
			name:          "metrics"
			containerPort: defaults.ports.metrics
		},
	]
	env: [
		{name: "XDS_CLUSTER", value:          _Name},
		{name: "ENVOY_ADMIN_LOG_PATH", value: "/dev/stdout"},
		{name: "PROXY_DYNAMIC", value:        "true"},
		{name: "XDS_ZONE", value:             mesh.spec.zone},
		{name: "XDS_HOST", value:             defaults.xds_host},
		{name: "XDS_PORT", value:             "50000"},
		if config.spire {
			{name: "SPIRE_PATH", value: "/run/spire/socket/agent.sock"}
		},
	]
	resources: {
		limits: {  
			cpu: *"200m" | string
			memory: *"512Mi" | string
		}
		requests: {
			cpu: *"50m" | string
			memory: *"128Mi" | string
		}
		
	}
	volumeMounts:    #sidecar_volume_mounts + _volume_mounts
	imagePullPolicy: defaults.image_pull_policy
}

#sidecar_volume_mounts: {
	if config.spire {
		[{
			name:      "spire-socket"
			mountPath: "/run/spire/socket"
		}]
	}
	[...]
}

#sidecar_volumes: {
	if config.spire {
		[{
			name: "spire-socket"
			hostPath: {path: "/run/spire/socket", type: "DirectoryOrCreate"}
		}]
	}
	[...]
}

#spire_permission_requests: {
	if config.spire {
		hostPID: true
		// hostNetwork: true
		// dnsPolicy: "ClusterFirstWithHostNet"
	}
	...
}

