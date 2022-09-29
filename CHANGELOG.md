# Changelog

## vNEXT

### Added

- Updated `gm_oidc-authentication` filter to support pre/post Keycloak v17 
- `mesh.spec.zone` now defaults to `"default-zone"`
- Change TLS default for `oidc-authentication` and `oidc-validation` filters to true.
- Added or increased support for TLS config Bon `oidc-authentication` and `oidc-validation`

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
