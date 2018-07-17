#!/usr/bin/env bash

vpc_id=$(aws ec2 describe-vpcs --region us-east-2 | jq -r '.Vpcs[] | select(.IsDefault | not) | .VpcId')
aws ec2 delete-vpc --vpc-id $vpc_id
