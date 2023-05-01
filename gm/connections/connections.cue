package greymatter

import (
    envoytls "envoyproxy.io/extensions/transport_sockets/tls/v3"
    envoymatcher "envoyproxy.io/type/matcher/v3"
)

connect: #Connections & {
    // Embed our default mesh configurations for outbound
    // connections from our catalog.
    #Connect

    connections: {
        "mesh-a": #Connection & {
            url: "https://google.com"
            name: "adx-mesh-east"
            display_name: "ADO 1.8.2"
            route: #ConnectRoute & {
                _name: name
            }
        }
        "mesh-b": #Connection & {
            url: "https://bing.com"
            name: "adx-mesh-west"
            display_name: "ADO 1.8.1"
            route: #ConnectRoute & {
                _name: name
            }
            ssl_config: #ConnectSSLConfig & {
                match_subject_alt_names: [
                    envoytls.#SubjectAltNameMatcher & {
                        san_type: envoytls.SubjectAltNameMatcher_SanType_DNS
                        matcher: envoymatcher.#StringMatcher & {
                            exact: "spiffe://cluster.local/greymatter/edge"
                        }
                    }
                ]
            }
        }
    }
}
    
accept: #Connections & {
    // Embed our default mesh configurations for inbound
    // connections to our catalog.
    #Accept & {
        domain: #domain & {
            ssl_config: #AcceptSSLConfig
        }
    }

    connections: {}
}
