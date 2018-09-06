#!/bin/bash

db_host=
db_port=
db_admin_password=
db_ckan_password=
db_datastore_password=
external=

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
        --external)
            external=true
            ;;
    esac
    shift
done

set -e

echo "Waiting for apt lists lock to be free..."
while fuser /var/lib/apt/lists/lock &>/dev/null; do sleep .5; done
echo "Apt lists lock is free!"
apt update
echo "Waiting for apt lock to be free..."
while fuser /var/lib/dpkg/lock &>/dev/null; do sleep .5; done
echo "Apt lock is free!"

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

# Reindex the database
[ -n "${external}" ] && (
    source /usr/lib/ckan/default/bin/activate
    paster --plugin=ckan search-index rebuild --config=/etc/ckan/default/production.ini
)

# EC2 credentials expire after 6 hours. This will ensure these credentials are always up to date
mv /tmp/update-aws-credentials.sh /opt/update-aws-credentials.sh
sh /opt/update-aws-credentials.sh

systemctl restart apache2
systemctl restart nginx