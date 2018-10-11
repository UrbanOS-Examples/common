#!/usr/bin/env bash

main() {
    local -rx CLUSTER_TEMPLATE_FILE=${1}
    local -rx CLUSTER_NAME=${2}

    set -eux

    until create-cluster; do sleep 10 ; done
}

create-cluster() {
    cb cluster describe --name ${CLUSTER_NAME} \
        || cb cluster create \
            --cli-input-json ${CLUSTER_TEMPLATE_FILE} \
            --name ${CLUSTER_NAME} \
            --wait
}

main "${@}"
