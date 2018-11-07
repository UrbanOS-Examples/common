#!/usr/bin/env bash

main() {
    local -rx DB_URL=${1}
    local -rx DB_NAME=${2}
    local -rx DB_PASSWORD=${3}
    local -rx DB_TYPE=${4}

    set -eux

    until ensure-database; do sleep 10; done
}

ensure-database() {
    cb database list | grep -qw ${DB_NAME} \
        || cb database create postgres \
            --name ${DB_NAME} \
            --type ${DB_TYPE} \
            --url ${DB_URL} \
            --db-username ${DB_NAME} \
            --db-password ${DB_PASSWORD}
}

main "${@}"
