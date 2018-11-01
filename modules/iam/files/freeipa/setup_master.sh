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

IP=$(hostname -I | xargs)

cat << EOF > /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
${IP} ${hostname}.${hosted_zone} ${hostname}
EOF

hostnamectl set-hostname "${hostname}.${hosted_zone}"

dnf -y install freeipa-server

ipa-server-install \
  --ds-password=${admin_password} \
  --admin-password=${admin_password} \
  --hostname="${hostname}.${hosted_zone}" \
  --ip-address="${IP}" \
  --domain="${hosted_zone}" \
  --realm="${hosted_zone^^}" \
  --ntp-pool=us.pool.ntp.org \
  --unattended
