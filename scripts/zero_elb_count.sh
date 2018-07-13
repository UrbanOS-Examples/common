#!/usr/bin/env bash

function set_session {
    local role_json=$(aws sts assume-role --role-arn arn:aws:iam::073132350570:role/jenkins_role --role-session-name JenkinsWaitForInfra)
    export AWS_ACCESS_KEY_ID=$(echo $role_json     | jq -r '.Credentials.AccessKeyId')
    export AWS_SECRET_ACCESS_KEY=$(echo $role_json | jq -r '.Credentials.SecretAccessKey')
    export AWS_SESSION_TOKEN=$(echo $role_json     | jq -r '.Credentials.SessionToken')
}

function get_elb_number {
    local elb_json=$(aws elb describe-load-balancers --region us-east-2)
    echo $elb_json | jq '.LoadBalancerDescriptions | length'
}

set_session
(($(get_elb_number) == 0))
