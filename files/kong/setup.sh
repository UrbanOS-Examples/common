#!/bin/bash

db_host=
db_port=
db_admin_password=
db_kong_password=
ckan_internal_url=
kong_host=

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
        --db-kong-password)
            db_kong_password=${2}
            shift
            ;;
        --ckan-internal-url)
            ckan_internal_url=${2}
            shift
            ;;
        --kong-host)
            kong_host=${2}
            shift
            ;;
    esac
    shift
done

set -ex

yum install -y postgresql

# Turn off command trace so passwords don't get dumped to log in jenkins
set +x
# Update Kong user DB password
export PGPASSWORD=${db_admin_password}
psql="psql -h ${db_host} -p ${db_port} kong"

${psql} sysadmin -c "ALTER USER kong WITH PASSWORD '${db_kong_password}';"

# Set CKAN url in config stored in DB
export PGPASSWORD=${db_kong_password}
${psql} kong -c "UPDATE apis SET upstream_url = '${ckan_internal_url}', hosts = '[\"localhost\",\"api.smartcolumbusos.com\",\"${kong_host}\"]';"
set -x

mv /tmp/kong.conf /etc/kong/kong.conf

systemctl restart kong
