# greymatter.io Core CUE

Enterprise-level CUE files for core greymatter.io mesh configurations.

## quickstart

Do this after checkout to generate things that would need hand-edits, because they
cannot be committed into the repo:

```
./scripts/bootstrap && ./scripts/generate-manifest
```

Then, bring it up.

```
./rebuild
```

This way, if there is a bug, then it can simply be committed, rather than
a fix only described by somebody that thinks it should work.

Edits to inputs.cue should be committed. Once the dashboard basically works,
getting the certs setup should be enabled by default. Especially for gm-data,
gm-data cannot be used without the client coming in with an mTLS cert, because
USER\_DN is required to do anything useful at all. I am currently cheating,
by injecting a USER\_DN, only because mTLS is far too hard to get setup.

We can override the certs later, but eventually, this setup must be using
mTLS on startup, by default.




## Prerequisites

- [CUE CLI](https://cuelang.org/docs/install/) v0.5.0
- pytest


## CUE Libraries

This project makes use of git submodules for dependency management. The
<https://github.com/greymatter-io/greymatter-cue> submodule provides the
baseline greymatter.io Control Plane CUE schema.

## Getting Started

Fetch all necessary dependencies:

```sh
./scripts/bootstrap
```

> NOTE: If <https://github.com/greymatter-io/greymatter-cue> is updated, you
> can re-run this script to pull down the latest version.

## Verify CUE configurations

By running the following commands, you can do a quick sanity check to
ensure that the CUE evaluates correctly. If you receive any errors, you
will need to fix them before greymatter.io can successfully apply the  configurations to your mesh.

```sh
# evaluate control plane configurations
cue eval -c ./gm/outputs --out text -e mesh_configs_yaml
```

```sh
# evaluate Kubernetes manifests
cue eval -c ./k8s/outputs --out text -e k8s_manifests_yaml
```
