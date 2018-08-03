#!/usr/bin/env bash

./setup_aws_creds.sh $1 $2

LoadBalancersInVpc=$(aws elbv2 describe-load-balancers | jq '[.LoadBalancers[] | select(.VpcId == "'"$vpc_id"'").LoadBalancerArn]' | jq -r '.[]')

for LoadBalancerArn in $LoadBalancersInVpc
do
   echo $LoadBalancerArn
   MatchingTagOnALB=$(aws elbv2 describe-tags --resource-arns $LoadBalancerArn | grep 'scos.delete.on.teardown' | wc -l)
   if [ "${MatchingTagOnALB}" -gt 0 ]; then
        ListenerArns=$(aws elbv2 describe-listeners --load-balancer-arn $LoadBalancerArn | jq '[.Listeners[].ListenerArn]' | jq -r '.[]')
        TargetGroupArns=$(aws elbv2 describe-target-groups --load-balancer-arn $LoadBalancerArn | jq '[.TargetGroups[].TargetGroupArn]' | jq -r '.[]')
        
        for ListenerArn in $ListenerArns
        do
            echo "Deleteing.... $ListenerArn"
            aws elbv2 delete-listener --listener-arn $ListenerArn
        done

        echo "Deleting.... $LoadBalancerArn"
        aws elbv2 delete-load-balancer --load-balancer-arn $LoadBalancerArn

        for TargetGroupArn in $TargetGroupArns
        do
            echo "Deleteing.... $TargetGroupArn"
            aws elbv2 delete-target-group --target-group-arn $TargetGroupArn
        done

   fi
done

exit 0