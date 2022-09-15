package greymatter

import (
	appsv1 "k8s.io/api/apps/v1"
	corev1 "k8s.io/api/core/v1"
)

_authRealms: string | *"/realms/"
if defaults.edge.oidc.keycloak_pre_17 != _|_ {
	if defaults.edge.oidc.keycloak_pre_17 {
		_authRealms: "/auth/realms/"
	}

}

let Name = "dashboard"
dashboard: [

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
					}
				}
				spec: #spire_permission_requests & {
					containers: [
						#sidecar_container_block & {_Name: Name},

						{
							name:  Name
							image: mesh.spec.images[Name]
							ports: [{
								name:          "app"
								containerPort: 1337
							}]
							env: [
								{name: "BASE_URL", value:                     "/services/\(name)/"},
								{name: "FABRIC_SERVER", value:                "/services/catalog/"},
								{name: "CONFIG_SERVER", value:                "/services/control-api/v1.0"},
								{name: "PROMETHEUS_SERVER", value:            "/services/prometheus/api/v1/"},
								{name: "REQUEST_TIMEOUT", value:              "15000"},
								{name: "USE_PROMETHEUS", value:               "\(config.enable_historical_metrics)"},
								{name: "DISABLE_PROMETHEUS_ROUTES_UI", value: "true"},
								{name: "ENABLE_INLINE_DOCS", value:           "true"},
								{name: "REDIS_HOST", value:                   "\(defaults.redis_host)"},
								{name: "REDIS_PORT", value:                   "6379"},
								{name: "KEYCLOAK_CLIENT_ID", value:           "\(defaults.edge.oidc.client_id)"},
								{name: "KEYCLOAK_CLIENT_SECRET", value:       "\(defaults.edge.oidc.client_secret)"},
								{name: "KEYCLOAK_AUTH_URL", value:            "\(defaults.edge.oidc.endpoint)\(_authRealms)\(defaults.edge.oidc.realm)/protocol/openid-connect/token"},
							]
							resources: {
								limits: {cpu: "200m", memory: "1Gi"}
								requests: {cpu: "100m", memory: "500Mi"}
							}
							volumeMounts: [
								{
									name:      "feature-flag-config"
									mountPath: "/usr/src/app/config"
								},
							]
							imagePullPolicy: defaults.image_pull_policy
						},
					]
					volumes: #sidecar_volumes + [
							{
							name: "feature-flag-config"
							configMap: {name: "feature-flag-config", defaultMode: 420}
						},
					]
					imagePullSecrets: [{name: defaults.image_pull_secret_name}]
				}
			}
		}
	},

	corev1.#ConfigMap & {
		apiVersion: "v1"
		kind:       "ConfigMap"
		metadata: {
			name:      "feature-flag-config"
			namespace: mesh.spec.install_namespace
		}
		data: {
			"featureFlagConfig.json": """
				{
				  "health": true,
				  "jwtMetadata": false,
				  "anomalyDetection": false
				}
				"""
		}
	},
]
