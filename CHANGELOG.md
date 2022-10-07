# Changelog

## vNEXT

### Changed

- Prometheus and Redis now pulling from Quay because of Docker Hub rate limiting
- Replaced `+` with `list.Concat` in long concatenations to improve performance

### Fixed

- OpenShift support for Prometheus and Vector
- Regression where observables pipeline egress cluster looked for non-existent certificates

## 0.11.0 (October 4th, 2022)

### Added

- Updated `gm_oidc-authentication` filter to support pre/post Keycloak v17 
- Added or increased support for TLS config Bon `oidc-authentication` and `oidc-validation`
- Integration tests for gitops, multi-operator deployment, and sidecar injection
- Automatically reorder enabled filters to enforce correct behavior.
- Eased manually-mounted mTLS certificates for internal mTLS (options now in inputs.cue)

### Changed

- `mesh.spec.zone` now defaults to `"default-zone"`
- Change TLS default for `oidc-authentication` and `oidc-validation` filters to true.

### Fixed 

- Prevent warnings during operator.yaml manifest application by removing namespace creations from the manifests (which were duplicates of user-created namespaces described in the documentation)

### Removed

- Removed deprecated generate_webhook_certs value from inputs.cue

## 0.10.0 (September 13, 2022)

### Changed

- Mesh CRD, webhooks, and associated permissions removed
- Removed `zone` from inputs.cue to prevent breaking mesh changes

### Fixed

- Fixed ability to override CircuitBreakers per service

### Added

- Added support for an external Prometheus
- Added better comments to gm/outputs/intermediates.cue
- Operator namespace is now configurable
- Set default Kubernetes resource requests
- Updated greymatter-cue to https://github.com/greymatter-io/greymatter-cue/commit/2f3119ff1af7061f833b9fdeab8549a1b318d957
- Added support for external Spire
- Added audit pipeline confgurations
- Add JWT Security filter and service toggles

## 0.9.3 (August 11, 2022)

### Changed

- Stable release with gm-operator v0.9.3
