#!/bin/bash

artifacts=(
        "https://greymatter.jfrog.io/artifactory/generic/greymatter-cli/greymatter-cli_<VERSION>_linux_amd64.tar.gz"
        "https://greymatter.jfrog.io/artifactory/generic/greymatter-catalog/greymatter-catalog_<VERSION>_linux_amd64.tar.gz"
        "https://greymatter.jfrog.io/artifactory/generic/greymatter-control/greymatter-control_<VERSION>_linux_amd64.tar.gz"
        "https://greymatter.jfrog.io/artifactory/generic/greymatter-control-api/greymatter-control-api_<VERSION>_linux_amd64.tar.gz"
        "https://greymatter.jfrog.io/artifactory/generic/greymatter-dashboard/greymatter-dashboard_<VERSION>_linux_amd64.tar.gz"
        "https://greymatter.jfrog.io/artifactory/generic/greymatter-proxy/greymatter-proxy_<VERSION>-ubuntu_linux_amd64.tar.gz"
        "https://greymatter.jfrog.io/artifactory/generic/greymatter-core/greymatter-core_<VERSION>_none_none.tar.gz"
        "https://greymatter.jfrog.io/artifactory/generic/greymatter-audits/greymatter-audits_<VERSION>_linux_amd64.tar.gz"
)

USERNAME=$1
API_KEY=$2

if [[ -z "$USERNAME" ]] || [[ -z "$API_KEY" ]]; then
    echo "${BASH_SOURCE[0]} <username> <api_key>"
    echo "To get an api key navigate to the following and generate your own key:"
    echo "https://www.jfrog.com/confluence/display/JFROG/User+Profile"
    echo "You will need a greymatter.io account."
    exit 1
fi


for artifact in "${artifacts[@]}"; do
    echo "downloading $artifact"
    curl -s -L -u $USERNAME:$API_KEY \
        $artifact \
        -o $( echo $artifact | cut -d/ -f7 )
done
