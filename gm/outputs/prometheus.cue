// Grey Matter configuration for Prometheus's sidecar

package greymatter

let Name = "prometheus"
let LocalName = "\(Name)_local"
let EgressToRedisName = "\(Name)_egress_to_redis"

prometheus_config: [
	// sidecar->prometheus
	#domain & {domain_key: LocalName},
	#listener & {
		listener_key:          LocalName
		_spire_self:           Name
		_gm_observables_topic: Name
		_is_ingress:           true
	},
	#cluster & {cluster_key: LocalName, _upstream_port: 9090},
	#route & {route_key:     LocalName},

	// egress->redis
	#domain & {domain_key: EgressToRedisName, port: defaults.ports.redis_ingress},
	#cluster & {
		cluster_key:  EgressToRedisName
		name:         defaults.redis_cluster_name
		_spire_self:  Name
		_spire_other: defaults.redis_cluster_name
	},
	#route & {route_key: EgressToRedisName}, // unused route must exist for the cluster to be registered with sidecar
	#listener & {
		listener_key:  EgressToRedisName
		ip:            "127.0.0.1" // egress listeners are local-only
		port:          defaults.ports.redis_ingress
		_tcp_upstream: defaults.redis_cluster_name // NB this points at a cluster name, not key
	},

	// shared proxy object
	#proxy & {
		proxy_key: Name
		domain_keys: [LocalName, EgressToRedisName]
		listener_keys: [LocalName, EgressToRedisName]
	},

	// edge->sidecar
	#cluster & {
		cluster_key:  Name
		_spire_other: Name
	},
	#route & {domain_key: "edge"
				route_key: Name
		route_match: {
			path: "/services/prometheus/"
		}
		redirects: [
			{
				from:          "^/services/prometheus$"
				to:            route_match.path
				redirect_type: "permanent"
			},
		]
		prefix_rewrite: "/"
	},
]
