package greymatter

import (
	corev1 "k8s.io/api/core/v1"
	"github.com/greymatter-io/common/api/meshv1"
)

config: {
	// Flags
	// use Spire-based mTLS (ours or another)
	spire: bool | *false @tag(spire,type=bool)
	// deploy our own server and agent
	deploy_spire: bool | *spire @tag(use_spire,type=bool)
	// if we're deploying into OpenShift, request extra permissions
	openshift: bool | *false @tag(openshift,type=bool)
	// deploy and configure Prometheus for historical metrics in the Dashboard
	enable_historical_metrics: bool | *true @tag(enable_historical_metrics,type=bool)
	// deploy and configure audit pipeline for observability telemetry
	enable_audits: bool | *true @tag(enable_audits,type=bool)
	// whether to automatically copy the image pull secret to watched namespaces for sidecar injection
	auto_copy_image_pull_secret: bool | *true @tag(auto_copy_image_pull_secret, type=bool)
	// namespace the operator will deploy into
	operator_namespace: string | *"gm-operator" @tag(operator_namespace, type=string)

	cluster_ingress_name: string | *"cluster" // For OpenShift deployments, this is used to look up the configured ingress domain

	// currently just controls k8s/outputs/operator.cue for debugging
	debug: bool | *false @tag(debug,type=bool)
	// test=true turns off GitOps, telling the operator to use the baked-in CUE
	test: bool | *false @tag(test,type=bool) // currently just turns off GitOps so CI integration tests can manipulate directly
}

mesh: meshv1.#Mesh & {
	metadata: {
		name: string | *"greymatter-mesh"
	}
	spec: {
		install_namespace: string | *"greymatter"
		watch_namespaces:  [...string] | *["default", "plus", "examples"]
		images: {
			proxy:       string | *"quay.io/greymatterio/gm-proxy:1.7.1"
			catalog:     string | *"quay.io/greymatterio/gm-catalog:3.0.5"
			dashboard:   string | *"quay.io/greymatterio/gm-dashboard:connections"
			control:     string | *"quay.io/greymatterio/gm-control:1.7.3"
			control_api: string | *"quay.io/greymatterio/gm-control-api:1.7.3"
			redis:       string | *"quay.io/quay/redis:latest"
			prometheus:  string | *"quay.io/prometheus/prometheus:v2.36.2"
		}
	}
}

defaults: {
	image_pull_secret_name: string | *"gm-docker-secret"
	image_pull_policy:      corev1.#enumPullPolicy | *corev1.#PullAlways
	xds_host:               "controlensemble.\(mesh.spec.install_namespace).svc.cluster.local"
	sidecar_list:           [...string] | *["dashboard", "catalog", "controlensemble", "edge", "redis", "prometheus", "jwtsecurity", "observables"]
	proxy_port_name:        "proxy" // the name of the ingress port for sidecars - used by service discovery
	redis_cluster_name:     "greymatter-datastore"
	redis_host:             "\(redis_cluster_name).\(mesh.spec.install_namespace).svc.cluster.local"
	redis_port:             6379
	redis_db:               0
	redis_username:         ""
	redis_password:         ""
	// key names for applied-state backups to Redis - they only need to be unique.
	gitops_state_key_gm:      "\(config.operator_namespace).gmHashes"
	gitops_state_key_k8s:     "\(config.operator_namespace).k8sHashes"
	gitops_state_key_sidecar: "\(config.operator_namespace).sidecarHashes"

	ports: {
		default_ingress: 10808
		edge_ingress:    defaults.ports.default_ingress
		redis_ingress:   10910
		metrics:         8081
	}

	images: {
		operator:    string | *"quay.io/greymatterio/operator:0.12.0" @tag(operator_image)
		vector:      string | *"timberio/vector:0.22.0-debian"
		observables: string | *"quay.io/greymatterio/observables:1.1.3"
	}

	// The external_host field instructs greymatter to install Prometheus or
	// uses an external one. If enable_historical_metrics is true and external_host
	// is empty, then greymatter will install Prometheus into the greymatter
	// namespace. If enable_historical_metrics is true and external_host has a
	// value, greymatter will not install Prometheus into the greymatter namespace
	// and will connect to the external Prometheus via a sidecar
	// (e.g. external_host: prometheus.metrics.svc).
	prometheus: {
		external_host: ""
		port:          9090
		tls: {
			enabled:     false
			cert_secret: "gm-prometheus-certs"
		}
	}

	// audits configuration applies to greymatter's observability pipeline and are
	// used when config.enable_audits is true.  
	audits: {
		// index determines the index ID in Elasticsearch. The default naming convention
		// will generate a new index each month. The index configuration can be changed
		// to create more or less indexes depending on your storage and performance requirements.
		index: "gm-audits-%Y-%m"
		// elasticsearch_host can be an IP address or DNS hostname to your Elasticsearch instance.
		elasticsearch_host: ""
		// elasticsearch_port is the port of your Elasticsearch instance.
		elasticsearch_port: 443
		// mounted_certs determines whether the observables application uses certificates
		// mounted at /etc/proxy/tls/sidecar in the observables application's sidecar. 
		mounted_certs: bool | *false
		// elasticsearch_endpoint is the full endpoint containing protocol, host, and port
		// of your Elasticsearch instance. This is used by to sync audit data
		// with Elasticsearch.
		elasticsearch_endpoint: "https://\(elasticsearch_host):\(elasticsearch_port)"
	}

	edge: {
		key: "edge"
		// edge.enable_tls toggles internal mtls connections between greymatter core components
		// by default the internal and external secrets are the same however if you want to
		// have different certs for the ingress and internal connections (this is the case for prod)
		// then you will need to add those certs to another secret and specity that
		// below at defaults.core_internal_tls_certs.cert_secret.
		enable_tls:  false
		secret_name: "gm-edge-ingress-certs"
		oidc: {
			endpoint_host: ""
			endpoint_port: 0
			endpoint:      "https://\(endpoint_host):\(endpoint_port)"
			domain:        ""
			client_id:     "\(defaults.edge.key)"
			client_secret: ""
			realm:         ""
			jwt_authn_provider: {
				keycloak: {
					audiences: ["\(defaults.edge.key)"]
					local_jwks: {
						inline_string: #"""
					  {}
					  """#
					}
					// If you want to use a remote JWKS provider, comment out local_jwks above, and
					// uncomment the below remote_jwks configuration. There are coinciding configurations
					// in ./gm/outputs/edge.cue that you will also need to uncomment.
					// remote_jwks: {
					//  http_uri: {
					//   cluster: "edge_to_keycloak" // this key should be unique across the mesh
					//  }
					// }
				}
			}
		}
	} // edge

	spire: {
		// Namespace of the Spire server
		namespace: "spire"
		// Trust domain must match what's configured at the server
		trust_domain: "greymatter.io"
		// The mount path of the spire socket for communication with the agent
		socket_mount_path: "/run/spire/socket"
		// When config.deploy_spire=true, we inject a secret. This sets the name of that secret
		ca_secret_name: "server-ca"
		// should we request a host mount for the socket, or normal volume mount? If true, also requests hostPID permission
		host_mount_socket: true
	}

	core_internal_tls_certs: {
		// use npe cert for internal mtls
		// Name of kubernetes secret to be mounted
		cert_secret: string | *defaults.edge.secret_name
	}

} // defaults
