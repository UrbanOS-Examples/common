#!/bin/bash

db_host=
db_port=
db_admin_password=
db_ckan_password=
db_datastore_password=

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
    esac
    shift
done

set -ex

sudo systemctl stop apt-daily

apt update && apt install -y jq postgresql-client

sudo systemctl start apt-daily

# Inject host nameserver into nginx config because nginx doesn't use host nameservers for resolution
nameserver=$(cat /etc/resolv.conf | grep nameserver | cut -d ' ' -f 2)
sed -i "s/#{NAMESERVER}/${nameserver}/" /tmp/nginx.conf

# Recombobulate Nginx configs
rm -rf /etc/nginx/sites-{enabled,available}/*
mv /tmp/nginx.conf /etc/nginx/sites-available/ckan
ln -s /etc/nginx/sites-available/ckan /etc/nginx/sites-enabled/ckan

# Turn off command trace so aws secret key doesn't get dumped to log in jenkins
set +x
# Inject EC2 instance AWS credentials to CKAN config
access_key=$(curl http://169.254.169.254/latest/meta-data/iam/security-credentials/ckan_ec2/ | jq '.AccessKeyId')
secret_key=$(curl http://169.254.169.254/latest/meta-data/iam/security-credentials/ckan_ec2/ | jq '.SecretAccessKey')
sed -i 's|#{DRIVER_OPTIONS}|{"key":'${access_key}',"secret":'${secret_key}'}|' /tmp/production.ini
set -x

mv /tmp/production.ini /etc/ckan/default/production.ini

# Turn off command trace so passwords don't get dumped to log in jenkins
set +x
# Upgrade db non-admin passwords
export PGPASSWORD=${db_admin_password}
psql="psql -h ${db_host} -p ${db_port} ckan_default sysadmin"

${psql} -c "ALTER USER ckan_default WITH PASSWORD '${db_ckan_password}';"
${psql} -c "ALTER USER datastore_default WITH PASSWORD '${db_datastore_password}';"
set -x

systemctl restart apache2
systemctl restart nginx