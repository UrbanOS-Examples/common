#!/usr/bin/env bash

./setup_aws_creds.sh $1 $2

function get_elb_number {
    echo $(aws elb describe-load-balancers | jq '[.LoadBalancerDescriptions[] | select(.VPCId == "'"${vpc_id}"'")] | length')
}

numlb=$(get_elb_number)

rm -f ${awsconfig}

if [ "${numlb}" -gt 0 ]; then
    exit 1
fi

exit 0
