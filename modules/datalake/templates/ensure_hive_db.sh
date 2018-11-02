#!/usr/bin/env bash

main() {
    local -rx HIVE_DB_URL=${1}
    local -rx HIVE_DB_NAME=${2}
    local -rx HIVE_DB_PASSWORD=${3}

    set -eux

    until ensure-hive; do sleep 10; done
}

ensure-hive() {
    cb database list | grep -qw ${HIVE_DB_NAME} \
        || cb database create postgres \
            --name ${HIVE_DB_NAME} \
            --type HIVE \
            --url ${HIVE_DB_URL} \
            --db-username hive \
            --db-password ${HIVE_DB_PASSWORD}
}

main "${@}"
