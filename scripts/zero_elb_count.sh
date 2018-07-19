#!/usr/bin/env bash

environment=$1

function help {
    echo "Usage: $1 ENVIRONMENT"
}

if [ ! $environment ]; then help; exit 1; fi

role_arn=$(grep role_arn backends/${environment}.conf | awk '{ print $3; }' | sed -e 's/^"//' -e 's/"$//')
region=$(grep region backends/${environment}.conf | awk '{ print $3; }' | sed -e 's/^"//' -e 's/"$//')

awsconfig=$(mktemp)

cat << EOF >> ${awsconfig}
[default]
region = ${region}
aws_access_key_id = ${AWS_ACCESS_KEY_ID}
aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}
role_arn = ${role_arn}
EOF

export AWS_CONFIG_FILE=${awsconfig}

function get_elb_number {
  local elb_json=$(aws elb describe-load-balancers)
  echo $elb_json | jq '.LoadBalancerDescriptions | length'
}

retval=(($(get_elb_number) == 0))

rm -f ${awsconfig}

exit ${retval}
