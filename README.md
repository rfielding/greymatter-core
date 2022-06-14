# Grey Matter Common CUE

Common CUE files for core Grey Matter mesh configurations.

## Prerequisites

- [CUE CLI](https://cuelang.org/docs/install/)

## Dependencies

This project makes use of git submodules for dependency management.

## Getting Started

Fetch all necessary dependencies:

```sh
./scripts/bootstrap
```

## Generate mesh configs

```sh
(
  cue eval -c ./gm/outputs --out text -e mesh_configs_yaml
)
```
