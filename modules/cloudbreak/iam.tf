data "aws_caller_identity" "current" {}

// if this changes, there is a chance that deployed clusters will be orphaned
resource "aws_iam_role" "cloudbreak_ec2" {
  name = "${terraform.workspace}_cloudbreak_ec2"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow"
      }
    ]
}
EOF
}

resource "aws_iam_instance_profile" "cloudbreak" {
  name = "${terraform.workspace}_cloudbreak"
  role = "${aws_iam_role.cloudbreak_ec2.name}"
}

resource "aws_iam_role_policy" "cloudbreak_role_assumption" {
  name = "cloudbreak_role_assumption_policy"
  role = "${aws_iam_role.cloudbreak_ec2.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": {
        "Sid": "AssumeDefaultCredentialRole",
        "Effect": "Allow",
        "Action": ["sts:AssumeRole"],
        "Resource": "*"
    }
}
EOF
}

resource "aws_iam_role" "cloudbreak_credential" {
  name = "${terraform.workspace}_cloudbreak_credential"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
                ]
            },
            "Action": "sts:AssumeRole",
            "Condition": {}
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "cloudbreak_credential" {
  name = "cloudbreak_credential_policy"
  role = "${aws_iam_role.cloudbreak_credential.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "cloudformation:CreateStack",
                "cloudformation:DeleteStack",
                "cloudformation:DescribeStackEvents",
                "cloudformation:DescribeStackResource",
                "cloudformation:DescribeStacks"
            ],
            "Resource": [
                "*"
            ]
        },
        {
          "Effect": "Allow",
          "Action": [
            "ec2:AllocateAddress",
            "ec2:AssociateAddress",
            "ec2:AssociateRouteTable",
            "ec2:AuthorizeSecurityGroupIngress",
            "ec2:DescribeRegions",
            "ec2:DescribeAvailabilityZones",
            "ec2:CreateRoute",
            "ec2:CreateRouteTable",
            "ec2:CreateSecurityGroup",
            "ec2:CreateSubnet",
            "ec2:CreateTags",
            "ec2:CreateVpc",
            "ec2:ModifyVpcAttribute",
            "ec2:DeleteSubnet",
            "ec2:CreateInternetGateway",
            "ec2:CreateKeyPair",
            "ec2:DeleteKeyPair",
            "ec2:DisassociateAddress",
            "ec2:DisassociateRouteTable",
            "ec2:ModifySubnetAttribute",
            "ec2:ReleaseAddress",
            "ec2:DescribeAddresses",
            "ec2:DescribeImages",
            "ec2:DescribeInstanceStatus",
            "ec2:DescribeInstances",
            "ec2:DescribeInternetGateways",
            "ec2:DescribeKeyPairs",
            "ec2:DescribeRouteTables",
            "ec2:DescribeSecurityGroups",
            "ec2:DescribeSubnets",
            "ec2:DescribeVpcs",
            "ec2:DescribeSpotInstanceRequests",
            "ec2:DescribeVpcAttribute",
            "ec2:ImportKeyPair",
            "ec2:AttachInternetGateway",
            "ec2:DeleteVpc",
            "ec2:DeleteSecurityGroup",
            "ec2:DeleteRouteTable",
            "ec2:DeleteInternetGateway",
            "ec2:DeleteRouteTable",
            "ec2:DeleteRoute",
            "ec2:DetachInternetGateway",
            "ec2:RunInstances",
            "ec2:StartInstances",
            "ec2:StopInstances",
            "ec2:TerminateInstances"
          ],
          "Resource": [
            "*"
          ]
        },
        {
          "Effect": "Allow",
          "Action": [
            "iam:ListRolePolicies",
            "iam:GetRolePolicy",
            "iam:ListAttachedRolePolicies",
            "iam:ListInstanceProfiles",
            "iam:PutRolePolicy",
            "iam:PassRole",
            "iam:GetRole"
          ],
          "Resource": [
            "*"
          ]
        },
        {
          "Effect": "Allow",
          "Action": [
            "autoscaling:CreateAutoScalingGroup",
            "autoscaling:CreateLaunchConfiguration",
            "autoscaling:DeleteAutoScalingGroup",
            "autoscaling:DeleteLaunchConfiguration",
            "autoscaling:DescribeAutoScalingGroups",
            "autoscaling:DescribeLaunchConfigurations",
            "autoscaling:DescribeScalingActivities",
            "autoscaling:DetachInstances",
            "autoscaling:ResumeProcesses",
            "autoscaling:SuspendProcesses",
            "autoscaling:UpdateAutoScalingGroup"
          ],
          "Resource": [
            "*"
          ]
        }
    ]
}
EOF
}
