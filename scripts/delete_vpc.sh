#!/usr/bin/env bash

environment=$1
vpc_id=$2

function help {
    echo "Usage: $1 ENVIRONMENT VPC_ID"
}

if [ ! $environment ]; then help; exit 1; fi
if [ ! $vpc_id ]; then help; exit 1; fi

role_arn=$(grep role_arn variables/${environment}.tfvars | awk '{ print $3; }' | sed -e 's/^"//' -e 's/"$//')
region=$(grep region variables/${environment}.tfvars | awk '{ print $3; }' | sed -e 's/^"//' -e 's/"$//')

awsconfig=$(mktemp)

cat << EOF >> ${awsconfig}
[default]
region = ${region}
aws_access_key_id = ${AWS_ACCESS_KEY_ID}
aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}
role_arn = ${role_arn}
EOF

export AWS_CONFIG_FILE=${awsconfig}

aws ec2 delete-vpc --vpc-id $vpc_id

rm -f ${awsconfig}

exit 0
