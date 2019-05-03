#!/usr/bin/env bash
set -euo pipefail

cd "$( dirname "${BASH_SOURCE[0]}" )/.."

if [[ ! -d integration ]]; then
    echo -e "\n\033[0;31m** WARNING  No Integration tests **\033[0m"
    exit 0
fi

PACK_VERSION=${PACK_VERSION:-""}
source ./scripts/install_tools.sh $PACK_VERSION

export CNB_BUILD_IMAGE=${CNB_BUILD_IMAGE:-cfbuildpacks/cflinuxfs3-cnb-experimental:build}
export CNB_RUN_IMAGE=${CNB_RUN_IMAGE:-cfbuildpacks/cflinuxfs3-cnb-experimental:run}

# Always pull latest images
# Most helpful for local testing consistency with CI (which would already pull the latest)
docker pull $CNB_BUILD_IMAGE
docker pull $CNB_RUN_IMAGE

# Get GIT_TOKEN for github rate limiting
#GIT_TOKEN=${GIT_TOKEN:-"$(lpass show Shared-CF\ Buildpacks/concourse-private.yml | grep buildpacks-github-token | cut -d ' ' -f 2)"}
GIT_TOKEN=0cdb06445e713b9638bdf1ea50c10060fbd5e545
export GIT_TOKEN

echo "Run Buildpack Runtime Integration Tests"
set +e
go test -timeout 0 -mod=vendor ./integration/... -v -run Integration
exit_code=$?

if [ "$exit_code" != "0" ]; then
    echo -e "\n\033[0;31m** GO Test Failed **\033[0m"
else
    echo -e "\n\033[0;32m** GO Test Succeeded **\033[0m"
fi

exit $exit_code
