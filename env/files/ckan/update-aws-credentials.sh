#!/bin/bash

me=$(cd $(dirname ${0}); pwd)/$(basename ${0})

reschedule() {
    formatted_expiration=${formatted_expiration:-"now + 1 minute"}

    at -f "${me}" "${formatted_expiration}"
}

trap reschedule EXIT HUP INT QUIT PIPE TERM

# Inject EC2 instance AWS credentials to CKAN config
role_name=$(curl http://169.254.169.254/latest/meta-data/iam/security-credentials/ | grep 'ckan_ec2')
security_credentials=$(curl http://169.254.169.254/latest/meta-data/iam/security-credentials/${role_name}/)

access_key=$(echo ${security_credentials} | jq '.AccessKeyId')
secret_key=$(echo ${security_credentials} | jq '.SecretAccessKey')
expiration=$(echo ${security_credentials} | jq -r '.Expiration')
sed -i 's|^ckanext\.cloudstorage\.driver_options =.*$|ckanext\.cloudstorage\.driver_options = {"key":'${access_key}',"secret":'${secret_key}'}|' /etc/ckan/default/production.ini

systemctl reload apache2

formatted_expiration=$(date --date="${expiration} - 4 min" +'%H:%M %m/%d/%Y')