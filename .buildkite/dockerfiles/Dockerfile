# Greymatter Core CI Base Image
FROM --platform=linux/amd64 greymatter.jfrog.io/base-oci/universal:latest

ENV CUE_VERSION="v0.5.0-beta.5"

LABEL name="greymatter-core-ci" \
    maintainers="prod-ops@greymatter.io" \
    base="ubuntu-greymatter-base"

# Install packages
RUN apt update && \
    apt install -y wget git python3 python3-pip jq

# Install Python dependencies
RUN pip3 install -U pytest pyyaml jsonschema pyartifactory

# Install CUE
RUN wget -q -c "https://github.com/cue-lang/cue/releases/download/${CUE_VERSION}/cue_${CUE_VERSION}_linux_amd64.tar.gz"
RUN tar -C '/usr/local/bin' -xzf cue_${CUE_VERSION}_linux_amd64.tar.gz cue
RUN rm cue_${CUE_VERSION}_linux_amd64.tar.gz
