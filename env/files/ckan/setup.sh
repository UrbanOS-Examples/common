#!/bin/bash

db_host=
db_port=
db_admin_password=
db_ckan_password=
db_datastore_password=
ckan_role_name=

until [ ${#} -eq 0 ]; do
    case "${1}" in
        --db-host)
            db_host=${2}
            shift
            ;;
        --db-port)
            db_port=${2}
            shift
            ;;
        --db-admin-password)
            db_admin_password=${2}
            shift
            ;;
        --db-ckan-password)
            db_ckan_password=${2}
            shift
            ;;
        --db-datastore-password)
            db_datastore_password=${2}
            shift
            ;;
        --ckan-role-name)
            ckan_role_name=${2}
            shift
            ;;
    esac
    shift
done

set -ex

apt update
set +x
echo "Waiting for apt lock to be free..."
while fuser /var/lib/dpkg/lock &>/dev/null; do sleep .5; done
echo "Apt lock is free!"
# Given the frequency of checks, there is a latency between when fuser says the lock is free
# and when the lock actually acts free.  To compensate for this, we sleep for an additional
# second after the lock is observed to be free
sleep 1
set -x

apt install -y jq postgresql-client

# Inject host nameserver into nginx config because nginx doesn't use host nameservers for resolution
nameserver=$(cat /etc/resolv.conf | grep nameserver | cut -d ' ' -f 2)
sed -i "s/#{NAMESERVER}/${nameserver}/" /tmp/nginx.conf

# Recombobulate Nginx configs
rm -rf /etc/nginx/sites-{enabled,available}/*
mv /tmp/nginx.conf /etc/nginx/sites-available/ckan
ln -s /etc/nginx/sites-available/ckan /etc/nginx/sites-enabled/ckan

mv /tmp/production.ini /etc/ckan/default/production.ini

# Turn off command trace so passwords don't get dumped to log in jenkins
set +x
# Upgrade db non-admin passwords
export PGPASSWORD=${db_admin_password}
psql="psql -h ${db_host} -p ${db_port} ckan_default sysadmin"

${psql} -c "ALTER USER ckan_default WITH PASSWORD '${db_ckan_password}';"
${psql} -c "ALTER USER datastore_default WITH PASSWORD '${db_datastore_password}';"
set -x

# EC2 credentials expire after 6 hours. This will ensure these credentials are always up to date
sed -i "/#{CKAN_ROLE_NAME}/${ckan_role_name}/" /tmp/update-aws-credentials.sh
mv /tmp/update-aws-credentials.sh /opt/update-aws-credentials.sh
sh /opt/update-aws-credentials.sh

systemctl restart apache2
systemctl restart nginx