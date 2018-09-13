#!/bin/bash

db_host=
db_port=
db_admin_password=
db_ckan_password=
db_datastore_password=
s3_bucket_region=
external=

# CKAN uses libcloud for S3 storage drivers. The value is based on region
# https://libcloud.readthedocs.io/en/latest/storage/supported_providers.html
declare -A DRIVER_MAP
DRIVER_MAP=( [us-east-1]=S3 [us-east-2]=S3_US_EAST2 [us-west-1]=S3_US_WEST [us-west-2]=S3_US_WEST_OREGON )

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
        --s3-bucket-region)
            s3_bucket_region=${2}
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

# Add appropriate driver based on region
bucket_region=${DRIVER_MAP[$s3_bucket_region]}
sed -i "s/#{S3_BUCKET_REGION}/${bucket_region}/" /tmp/production.ini
mv /tmp/production.ini /etc/ckan/default/production.ini

# Turn off command trace so passwords don't get dumped to log in jenkins
set +x
# Upgrade db non-admin passwords
export PGPASSWORD=${db_admin_password}
psql="psql -h ${db_host} -p ${db_port} ckan_default sysadmin"

${psql} -c "ALTER USER ckan_default WITH PASSWORD '${db_ckan_password}';"
${psql} -c "ALTER USER datastore_default WITH PASSWORD '${db_datastore_password}';"
set -x

bash -ex /tmp/upgrade.sh

(
    source /usr/lib/ckan/default/bin/activate
    chown -R ubuntu:ubuntu /usr/lib/ckan/default/

    RUNAS=$(mktemp)
    cat <<EOF >"${RUNAS}"
#!/bin/bash

source /usr/lib/ckan/default/bin/activate

pip install boto ckanapi docopt || exit 1
pip uninstall -y ckanext-cloudstorage
pip uninstall -y ckanext-cloudstorage-master
rm -rf /usr/lib/ckan/default/src/ckanext-cloudstorage
pip install -U -e git+https://github.com/SmartColumbusOS/ckanext-cloudstorage.git@63f4f03f0c33b8725fe1eb7e9bc92587de90e8cf#egg=ckanext_cloudstorage || exit 1

cd /usr/lib/ckan/default/src/ckanext-cloudstorage || exit 1
paster cloudstorage initdb -c /etc/ckan/default/production.ini || exit 1
EOF
    chmod 644 "${RUNAS}"
    su -c "bash ${RUNAS}" ubuntu

    if [ -n "${external}" ]; then
        paster --plugin=ckan search-index rebuild --config=/etc/ckan/default/production.ini
        paster --plugin=ckan datastore set-permissions --config=/etc/ckan/default/production.ini | ${psql}

        # restart solr server
        service jetty8 restart
    fi
)

systemctl restart apache2
systemctl restart nginx