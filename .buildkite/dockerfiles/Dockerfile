# Greymatter Core CI Base Image
FROM --platform=linux/amd64 greymatter.jfrog.io/base-oci/universal:latest-20230531

LABEL name="greymatter-core-ci" \
    maintainers="prod-ops@greymatter.io" \
    base="ubuntu-greymatter-base"

# Install packages
RUN apt update && \
    apt install -y wget git python3 python3-pip jq

# Install Python dependencies
RUN pip3 install -U pytest pyyaml jsonschema pyartifactory
