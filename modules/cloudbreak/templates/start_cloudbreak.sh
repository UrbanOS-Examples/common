#!/usr/bin/env bash

main() {
    local -rx PROFILE_FILE=${1}

    set -eux

    configure-cloudbreak
    start-cloudbreak
    configure-cloudbreak-client
}

configure-cloudbreak() {
    source /etc/sysconfig/cloudbreak
    sudo cp ${PROFILE_FILE} ${CLOUDBREAK_HOME}/Profile
}

start-cloudbreak() {
    sudo systemctl enable cloudbreak
    sudo systemctl restart cloudbreak
}

configure-cloudbreak-client() {
    set +x
    source ${PROFILE_FILE}

    cb configure \
       --server ${PUBLIC_IP} \
       --username ${UAA_DEFAULT_USER_EMAIL} \
       --password ${UAA_DEFAULT_USER_PW}
    set -x
}

main "${@}"
