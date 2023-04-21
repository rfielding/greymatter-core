package greymatter

import (
	api "greymatter.io/api"
)

let external_mesh_connections_egress = "catalog_egress_for_connections"
let external_mesh_connections_ingress = "edge_ingress_for_connections"

#Mesh: {
    url: string
    name: string
    display_name: string
    ssl_config?: api.#ClusterSSLConfig
    route: #ConnectionsAcceptRoute | #ConnectionsConnectRoute
    cluster: {
        zone_key: string | *"default-zone"
        ...
    }
}

#ConnectionsAcceptRoute: #route & {
    _name: string
    _upstream_cluster_key: "catalog"
    domain_key: external_mesh_connections_ingress
    route_key: "\(_name)-route"
    route_match: {
        path: "/\(_name)"
    }
    redirects: [
        {
            from:          "^/\(_name)$"
            to:            route_match.path
            redirect_type: "permanent"
        },
    ]
    prefix_rewrite: ""
}

#ConnectionsConnectRoute: #route & {
    _name: string
    _upstream_cluster_key: "\(_name)-cluster"
    domain_key: external_mesh_connections_egress
    route_key: "\(_name)-route"
    prefix_rewrite: ""
    route_match: {
        path: "/\(_name)"
    }
    redirects: [
        {
            from:          "^/\(_name)$"
            to:            route_match.path
            redirect_type: "permanent"
        },
    ]
}

#ConnectionsAccept: {
    domain: #domain & {
        domain_key: external_mesh_connections_ingress
        port: 10710
        _trust_file:       "/etc/proxy/tls/edge/connections/ca.crt"
		_certificate_path: "/etc/proxy/tls/edge/connections/server.crt"
		_key_path:         "/etc/proxy/tls/edge/connections/server.key"
    }
    listener: #listener & {
        listener_key: external_mesh_connections_ingress
        _gm_observables_topic: external_mesh_connections_ingress
        ip: "0.0.0.0"
        port: 10710
        _is_ingress: true
    }
}

#ConnectionsConnect: {
    domain: #domain & {
        domain_key: external_mesh_connections_egress
        port: 10610
        // Set to true to force no ssl_config
        // on plaintext egress traffic
        _is_egress: true
    }
    listener: #listener & {
        listener_key: external_mesh_connections_egress
        _gm_observables_topic: external_mesh_connections_egress
        // egress listeners are local only
        ip: "127.0.0.1"
        port: 10610
    }
}

