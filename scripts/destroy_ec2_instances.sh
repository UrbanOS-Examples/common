#!/usr/bin/env bash

until [ ${#} -eq 0 ]; do
    case "${1}" in
        --vpc_id)
            vpc_id="${2}"
            shift
            ;;
        --region)
            region="${2}"
            shift
            ;;
        --role_arn)
            role_arn="${2}"
            shift
            ;;
        --tag_to_delete)
            tag_to_delete="${2}"
            shift
            ;;
    esac
    shift
done

if [[ -z ${vpc_id} || -z ${region} || -z ${role_arn} || -z ${tag_to_delete} ]]; then
  echo 'Missing arguments, include vpc_id, region, role_arn, and tag_to_delete'
  exit 1
fi

awsconfig=$(mktemp)

cat << EOF >> ${awsconfig}
[profile ${AWS_PROFILE}]
region = ${region}
role_arn = ${role_arn}
source_profile = ${AWS_PROFILE}
EOF

export AWS_CONFIG_FILE=${awsconfig}

InstanceIdsInVpc=$(aws ec2 describe-instances --filters Name=vpc-id,Values=${vpc_id} Name=tag-key,Values=$tag_to_delete | jq -r '.Reservations[].Instances[].InstanceId' | tr '\n' ' ')

echo "Terminating EC2 instances..."

aws ec2 terminate-instances --instance-ids $InstanceIdsInVpc

exit 0
