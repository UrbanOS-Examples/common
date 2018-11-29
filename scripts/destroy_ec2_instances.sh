#!/usr/bin/env bash

echo "In Destroy EC2 Script..."

vpc_id=$1
region=$2
role_arn=$3
tag_to_delete="CloudbreakClusterName"

awsconfig=$(mktemp)

cat << EOF >> ${awsconfig}
[profile ${AWS_PROFILE}]
region = ${region}
role_arn = ${role_arn}
source_profile = ${AWS_PROFILE}
EOF

export AWS_CONFIG_FILE=${awsconfig}

InstanceIdsInVpc=$(aws ec2 describe-instances --filters Name=vpc-id,Values=${vpc_id} Name=tag-key,Values=$tag_to_delete | jq -r '.Reservations[].Instances[].InstanceId' | tr '\n' ' ')

aws ec2 terminate-instances --instance-ids $InstanceIdsInVpc

exit 0
