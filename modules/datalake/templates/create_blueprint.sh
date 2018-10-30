#!/usr/bin/env bash

main() {
    local -rx BLUEPRINT_FILE=${1}
    local -rx BLUEPRINT_NAME=${2}

    set -eux

    until create-blueprint; do sleep 10 ; done
}

create-blueprint() {
    timeout 10 cb blueprint describe --name "${BLUEPRINT_NAME}" \
        || cb blueprint create from-file \
            --file ${BLUEPRINT_FILE} \
            --name "${BLUEPRINT_NAME}"
}

main "${@}"
