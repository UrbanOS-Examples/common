#!/usr/bin/env bash

main() {
    source /etc/sysconfig/cloudbreak

    set -eux

    start-cloudbreak
}

start-cloudbreak() {
    mv /tmp/Profile ${CLOUDBREAK_HOME}/Profile
    systemctl enable cloudbreak
    systemctl restart cloudbreak
}

main "${@}"