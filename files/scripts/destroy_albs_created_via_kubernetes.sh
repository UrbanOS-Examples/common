#!/usr/bin/env bash

vpc_id=$1
region=$2
role_arn=$3

awsconfig=$(mktemp)

cat << EOF >> ${awsconfig}
[profile ${AWS_PROFILE}]
region = ${region}
role_arn = ${role_arn}
source_profile = ${AWS_PROFILE}
EOF

export AWS_CONFIG_FILE=${awsconfig}

LoadBalancersInVpc=$(aws elbv2 describe-load-balancers | jq '[.LoadBalancers[] | select(.VpcId == "'"$vpc_id"'").LoadBalancerArn]' | jq -r '.[]')

for LoadBalancerArn in $LoadBalancersInVpc
do
   MatchingTagOnALB=$(aws elbv2 describe-tags --resource-arns $LoadBalancerArn | grep 'scos.delete.on.teardown' | wc -l)
   if [ "${MatchingTagOnALB}" -gt 0 ]; then
        ListenerArns=$(aws elbv2 describe-listeners --load-balancer-arn $LoadBalancerArn | jq '[.Listeners[].ListenerArn]' | jq -r '.[]')
        for ListenerArn in $ListenerArns
        do
            echo "Deleteing.... $ListenerArn"
            aws elbv2 delete-listener --listener-arn $ListenerArn
        done

        echo "Deleting.... $LoadBalancerArn"
        aws elbv2 delete-load-balancer --load-balancer-arn $LoadBalancerArn
   fi
done

TargetGroupsInVpc=$(aws elbv2 describe-target-groups | jq '[.TargetGroups[] | select(.VpcId == "'"$vpc_id"'").TargetGroupArn]' | jq -r '.[]')
for TargetGroupArn in $TargetGroupsInVpc
do
    MatchingTagOnTargetGroup=$(aws elbv2 describe-tags --resource-arns $TargetGroupArn | grep 'scos.delete.on.teardown' | wc -l)
    if [ "${MatchingTagOnTargetGroup}" -gt 0 ]; then
        echo "Deleting.... $TargetGroupArn"
        aws elbv2 delete-target-group --target-group-arn $TargetGroupArn
    fi
done

exit 0
