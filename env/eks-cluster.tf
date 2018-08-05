module "eks-cluster" {
  source  = "terraform-aws-modules/eks/aws"
  version = "1.3.0"

  cluster_name = "${var.kubernetes_cluster_name}"
  subnets      = "${module.vpc.private_subnets}"
  vpc_id       = "${module.vpc.vpc_id}"

  kubeconfig_aws_authenticator_command         = "heptio-authenticator-aws"
  kubeconfig_aws_authenticator_additional_args = ["-r", "${var.role_arn}"]

  worker_groups = [{
    name                 = "Workers"
    asg_desired_capacity = "3"
    asg_min_size         = "1"
    asg_max_size         = "6"
    instance_type        = "t2.medium"
  }]

  tags = {
    Environment = "${terraform.workspace}"
  }
}

resource "aws_iam_policy" "eks_work_alb_permissions" {
  name        = "eks_work_alb_permissions"
  description = "This policy allows EKS Worker nodes to do everything it needs to do with an ALB"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "123",
            "Effect": "Allow",
            "Action": [
                "tag:GetResources",
                
                "ec2:DescribeInstances",
                "ec2:DescribeVolumesModifications",
                "ec2:GetHostReservationPurchasePreview",
                "ec2:DescribeSnapshots",
                "ec2:DescribePlacementGroups",
                "ec2:GetConsoleScreenshot",
                "ec2:DescribeHostReservationOfferings",
                "ec2:DescribeInternetGateways",
                "ec2:GetLaunchTemplateData",
                "ec2:DescribeVolumeStatus",
                "ec2:DescribeScheduledInstanceAvailability",
                "ec2:DescribeSpotDatafeedSubscription",
                "ec2:DescribeVolumes",
                "ec2:DescribeFpgaImageAttribute",
                "ec2:DescribeExportTasks",
                "ec2:DescribeAccountAttributes",
                "ec2:DescribeNetworkInterfacePermissions",
                "ec2:DescribeReservedInstances",
                "ec2:DescribeKeyPairs",
                "ec2:DescribeNetworkAcls",
                "ec2:DescribeRouteTables",
                "ec2:DescribeReservedInstancesListings",
                "ec2:DescribeEgressOnlyInternetGateways",
                "ec2:DescribeSpotFleetRequestHistory",
                "ec2:DescribeLaunchTemplates",
                "ec2:DescribeVpcClassicLinkDnsSupport",
                "ec2:DescribeVpnConnections",
                "ec2:DescribeSnapshotAttribute",
                "ec2:DescribeVpcPeeringConnections",
                "ec2:DescribeReservedInstancesOfferings",
                "ec2:DescribeIdFormat",
                "ec2:DescribeVpcEndpointServiceConfigurations",
                "ec2:DescribePrefixLists",
                "ec2:GetReservedInstancesExchangeQuote",
                "ec2:DescribeVolumeAttribute",
                "ec2:DescribeInstanceCreditSpecifications",
                "ec2:DescribeVpcClassicLink",
                "ec2:DescribeImportSnapshotTasks",
                "ec2:DescribeVpcEndpointServicePermissions",
                "ec2:GetPasswordData",
                "ec2:DescribeScheduledInstances",
                "ec2:DescribeImageAttribute",
                "ec2:DescribeVpcEndpoints",
                "ec2:DescribeReservedInstancesModifications",
                "ec2:DescribeElasticGpus",
                "ec2:DescribeSubnets",
                "ec2:DescribeVpnGateways",
                "ec2:DescribeMovingAddresses",
                "ec2:DescribeAddresses",
                "ec2:DescribeInstanceAttribute",
                "ec2:DescribeRegions",
                "ec2:DescribeFlowLogs",
                "ec2:DescribeDhcpOptions",
                "ec2:DescribeVpcEndpointServices",
                "ec2:DescribeSpotInstanceRequests",
                "ec2:DescribeVpcAttribute",
                "ec2:GetConsoleOutput",
                "ec2:DescribeSpotPriceHistory",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribeAvailabilityZones",
                "ec2:DescribeNetworkInterfaceAttribute",
                "ec2:DescribeVpcEndpointConnections",
                "ec2:DescribeInstanceStatus",
                "ec2:DescribeHostReservations",
                "ec2:DescribeIamInstanceProfileAssociations",
                "ec2:DescribeTags",
                "ec2:DescribeLaunchTemplateVersions",
                "ec2:DescribeBundleTasks",
                "ec2:DescribeIdentityIdFormat",
                "ec2:DescribeImportImageTasks",
                "ec2:DescribeClassicLinkInstances",
                "ec2:DescribeNatGateways",
                "ec2:DescribeCustomerGateways",
                "ec2:DescribeVpcEndpointConnectionNotifications",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSpotFleetRequests",
                "ec2:DescribeHosts",
                "ec2:DescribeImages",
                "ec2:DescribeFpgaImages",
                "ec2:DescribeSpotFleetInstances",
                "ec2:DescribeSecurityGroupReferences",
                "ec2:DescribeVpcs",
                "ec2:DescribeConversionTasks",
                "ec2:DescribeStaleSecurityGroups",
                
                "waf-regional:GetRuleGroup",
                "waf-regional:GetRateBasedRuleManagedKeys",
                "waf-regional:GetRateBasedRule",
                "waf-regional:GetWebACLForResource",
                "waf-regional:GetRegexMatchSet",
                "waf-regional:GetWebACL",
                "waf-regional:GetXssMatchSet",
                "waf-regional:ListWebACLs",
                "waf-regional:ListIPSets",
                "waf-regional:ListRules",
                "waf-regional:ListRateBasedRules",
                "waf-regional:GetGeoMatchSet",
                "waf-regional:ListResourcesForWebACL",
                "waf-regional:GetRegexPatternSet",
                "waf-regional:GetSampledRequests",
                "waf-regional:ListGeoMatchSets",
                "waf-regional:ListActivatedRulesInRuleGroup",
                "waf-regional:GetChangeToken",
                "waf-regional:GetPermissionPolicy",
                "waf-regional:GetSqlInjectionMatchSet",
                "waf-regional:ListRegexMatchSets",
                "waf-regional:GetIPSet",
                "waf-regional:GetChangeTokenStatus",
                "waf-regional:ListRegexPatternSets",
                "waf-regional:ListSqlInjectionMatchSets",
                "waf-regional:ListXssMatchSets",
                "waf-regional:GetByteMatchSet",
                "waf-regional:GetRule",
                "waf-regional:GetSizeConstraintSet",
                "waf-regional:ListRuleGroups",
                "waf-regional:ListSizeConstraintSets",
                "waf-regional:ListByteMatchSets",
                "waf-regional:ListSubscribedRuleGroups",

                "acm:ListCertificates",
                "iam:ListServerCertificates",

                "elasticloadbalancing:*"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "eks_work_alb_permissions" {
  role       = "${module.eks-cluster.worker_iam_role_name}"
  policy_arn = "${aws_iam_policy.eks_work_alb_permissions.arn}"
}

output "eks-cluster-kubeconfig" {
  description = "Working kubeconfig to talk to the eks cluster."
  value       = "${module.eks-cluster.kubeconfig}"
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = "${var.kubernetes_cluster_name}"
}
