#!/usr/bin/env bash

set -e

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

IP=$(hostname -I | xargs)

cat << EOF > /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
$${IP} ${hostname}.${hosted_zone} ${hostname}
EOF

hostnamectl set-hostname "${hostname}.${hosted_zone}"

until dnf -y install freeipa-server; do
  sleep 10
done

if [[ "${hostname}" =~ "master" ]]; then
  /usr/sbin/ipa-server-install \
    --ds-password=${admin_password} \
    --admin-password=${admin_password} \
    --hostname="${hostname}.${hosted_zone}" \
    --ip-address="$${IP}" \
    --domain="${hosted_zone}" \
    --realm="${upper("${hosted_zone}")}" \
    --ntp-pool=us.pool.ntp.org \
    --unattended
else
  until curl -I --insecure "https://${hostname_prefix}-master.${hosted_zone}/ipa/ui/"; do
    sleep 30
  done
  /usr/sbin/ipa-client-install \
    --domain="${hosted_zone}" \
    --realm="${upper("${hosted_zone}")}" \
    --server="${hostname_prefix}-master.${hosted_zone}" \
    --hostname="${hostname}.${hosted_zone}" \
    --principal="admin@${upper("${hosted_zone}")}" \
    --password="${admin_password}" \
    --ntp-server=us.pool.ntp.org \
    --unattended
fi