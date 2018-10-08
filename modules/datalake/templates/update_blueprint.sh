#!/usr/bin/env bash

main() {
    local -rx BLUEPRINT_FILE=${1}
    local -rx BLUEPRINT_NAME=${2}

    set -eux

    until update-blueprint; do sleep 10 ; done
}

update-blueprint() {
    cb blueprint describe --name "${BLUEPRINT_NAME}" \
        || cb blueprint create from-file \
            --file ${BLUEPRINT_FILE} \
            --name "${BLUEPRINT_NAME}"
}

main "${@}"
