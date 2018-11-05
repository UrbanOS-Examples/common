#!/usr/bin/env bash

main() {
    local -rx LDAP_NAME=${1}
    local -rx LDAP_SERVER=${2}
    local -rx LDAP_PORT=${3}
    local -rx LDAP_DOMAIN=${4}
    local -rx LDAP_BIND_USER=${5}
    local -rx LDAP_BIND_PASSWORD=${6}
    local -rx LDAP_ADMIN_GROUP=${7}

    set -eux

    until ensure-ldap; do sleep 10; done
}

ensure-ldap() {
    cb ldap list | grep -qw ${LDAP_NAME} \
        || cb ldap create \
            --name ${LDAP_NAME} \
            --ldap-server ${LDAP_SERVER}:${LDAP_PORT} \
            --ldap-domain ${LDAP_DOMAIN} \
            --ldap-bind-dn uid=${LDAP_BIND_USER},cn=users,cn=accounts,${LDAP_DOMAIN} \
            --ldap-directory-type LDAP \
            --ldap-user-search-base cn=users,cn=accounts,${LDAP_DOMAIN} \
            --ldap-user-name-attribute uid \
            --ldap-user-object-class inetorgperson \
            --ldap-group-member-attribute member \
            --ldap-group-name-attribute cn \
            --ldap-group-object-class groupOfNames \
            --ldap-group-search-base cn=groups,cn=accounts,${LDAP_DOMAIN} \
            --ldap-bind-password ${LDAP_BIND_PASSWORD} \
            --ldap-admin-group ${LDAP_ADMIN_GROUP} \
            --ldap-user-dn-pattern uid={0}
}

main "${@}"
