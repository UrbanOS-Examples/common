#!/usr/bin/env bash

main() {
    local -rx CLUSTER_TEMPLATE_FILE=${1}
    local -rx CLUSTERNAME=${2}

    set -eux

    until ensure-cluster; do sleep 10; done
}

ensure-cluster() {
    cb cluster describe --name ${CLUSTERNAME} &>/dev/null \
        || cb cluster create \
            --cli-input-json ${CLUSTER_TEMPLATE_FILE} \
            --name ${CLUSTERNAME} \
            --wait

    (
        set -o pipefail
        cb cluster describe --name ${CLUSTERNAME} --output json \
            | jq -e 'any(.status; contains("AVAILABLE"))'
    )
}

main "${@}"
