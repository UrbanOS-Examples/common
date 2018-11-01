#!/usr/bin/env bash

hostname=
hosted_zone=
admin_password=

until [ ${#} -eq 0 ]; do
    case "${1}" in
        --hostname)
            hostname=${2}
            shift
            ;;
        --hosted-zone)
            hosted_zone=${2}
            shift
            ;;
        --admin-password)
            admin_password=${2}
            shift
            ;;
    esac
    shift
done

set -ex

echo "${admin_password}" | kinit "admin@${hosted_zone^^}"

until ipa host-find | grep ${hostname}; do
  sleep 10
done 

ipa hostgroup-add-member ipaservers --hosts "${hostname}.${hosted_zone}"
