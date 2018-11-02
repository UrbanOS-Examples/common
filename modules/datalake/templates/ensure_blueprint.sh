#!/usr/bin/env bash

main() {
    local -rx BLUEPRINT_FILE=${1}
    local -rx BLUEPRINT_NAME=${2}

    set -eux

    until ensure-blueprint; do sleep 10; done
}

ensure-blueprint() {
    cb blueprint describe --name "${BLUEPRINT_NAME}" \
        || cb blueprint create from-file \
            --file ${BLUEPRINT_FILE} \
            --name "${BLUEPRINT_NAME}" \
            --description "Created $(date)"
}

main "${@}"
