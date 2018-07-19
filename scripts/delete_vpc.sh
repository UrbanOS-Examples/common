#!/usr/bin/env bash

environment=$1
vpc_id=$2

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

aws ec2 delete-vpc --vpc-id $vpc_id

rm -f ${awsconfig}

true # Stopgap. Never fail the build.
