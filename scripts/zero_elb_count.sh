#!/usr/bin/env bash

environment=$1
vpc_id=$2
./setup_aws_creds.sh $environment $vpc_id

function get_elb_number {
    echo $(aws elb describe-load-balancers | jq '[.LoadBalancerDescriptions[] | select(.VPCId == "'"${vpc_id}"'")] | length')
}

numlb=$(get_elb_number)

rm -f ${awsconfig}

if [ "${numlb}" -gt 0 ]; then
    exit 1
fi

exit 0
