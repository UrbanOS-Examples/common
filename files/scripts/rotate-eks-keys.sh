#!/bin/bash
set -eo pipefail

git_root=$(git rev-parse --show-toplevel)
date=$(date +"%Y_%m_%d")
profile_prefix=$1

if [ -z $1 ]; then
    echo "You must specify your AWS_PROFILE prefix.  This script expects 3 profiles to exist in the AWS CLI config: \$prefix_dev, \$prefix_staging, and \$prefix_prod"
    exit 1
fi

for environment in "sandbox" "dev" "staging" "prod"
do
    export AWS_PROFILE=${profile_prefix}_${environment}
    if ! aws s3 ls 1>/dev/null 2>&1; then
        echo 1>&2 "AWS profile named ${AWS_PROFILE} not found or setup incorrectly"
        exit 1
    fi
done

for environment in "sandbox" "dev" "staging" "prod"
do
    echo creating key for $environment
    password=$(openssl rand 18 -base64)

    ssh-keygen -t rsa -b 4096 -P $password -f ./eks_${environment}_id_rsa_${date}

    export AWS_PROFILE=${profile_prefix}_${environment}

    aws secretsmanager create-secret --name eks_${environment}_key_password_${date} --secret-string ${password} --region us-west-2

    export AWS_PROFILE=${profile_prefix}
    aws secretsmanager create-secret --name eks_${environment}_private_key_${date} --secret-string "$(cat ./eks_${environment}_id_rsa_${date})" --region us-east-2

    # delete the old keyname and public key string 
    sed -i ''  "/key_pair_public_key.*/d" ${git_root}/variables/$environment.tfvars
    sed -i ''  "/key_pair_name.*/d" ${git_root}/variables/$environment.tfvars

    #append new values to tfvars file
    echo "key_pair_public_key = \"$(cat ./eks_${environment}_id_rsa_${date}.pub | tr -d '\n')\"" >> ${git_root}/variables/${environment}.tfvars        
    echo "key_pair_name = \"eks_key_${environment}_${date}\"" >> ${git_root}/variables/${environment}.tfvars
    
    terraform fmt ${git_root}/variables/${environment}.tfvars
    rm eks_${environment}_*
done

echo "Keys successfully created and saved to AWS.  Terraform will still need to be executed to complete these actions via Jenkins or manual terraform execution"
