#!/usr/bin/env bash

main() {
    local -rx HIVE_DB_URL=${1}
    local -rx HIVE_DB_NAME=${2}
    local -rx HIVE_DB_PASSWORD=${3}

    set -eux

    until update-hive-database-connection; do sleep 10 ; done
}

update-hive-database-connection() {
    timeout 10 cb database list | grep -qw ${HIVE_DB_NAME} \
        || timeout 10 cb database create postgres \
            --name ${HIVE_DB_NAME} \
            --type HIVE \
            --url ${HIVE_DB_URL} \
            --db-username hive \
            --db-password ${HIVE_DB_PASSWORD}
}

main "${@}"
