locals {
  kubernetes_cluster_name = "streaming-kube-${terraform.workspace}"
}

module "eks-cluster" {
  source = "github.com/SmartColumbusOS/terraform-aws-eks"
  # source  = "terraform-aws-modules/eks/aws"
  # version = "1.3.0"

  cluster_name = "${local.kubernetes_cluster_name}"
  subnets      = "${module.vpc.private_subnets}"
  vpc_id       = "${module.vpc.vpc_id}"

  kubeconfig_aws_authenticator_command         = "heptio-authenticator-aws"
  kubeconfig_aws_authenticator_additional_args = ["-r", "${var.role_arn}"]

  worker_groups = [{
    name                 = "Workers"
    asg_min_size         = "${var.min_num_of_workers}"
    asg_max_size         = "${var.max_num_of_workers}"
    instance_type        = "t2.medium"
    key_name             = "${aws_key_pair.cloud_key.key_name}"
  }]

  tags = {
    Environment = "${terraform.workspace}"
  }
}

resource "aws_security_group_rule" "allow_all_sg_to_eks_worker_sg" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = "${module.eks-cluster.worker_security_group_id}"
  source_security_group_id = "${aws_security_group.allow_all.id}"
}

resource "aws_iam_policy" "eks_work_alb_permissions" {
  name        = "eks_work_alb_permissions-${terraform.workspace}"
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

                "ec2:Describe*",
                "ec2:GetLaunchTemplateData",
                "ec2:GetConsoleOutput",
                "ec2:GetPasswordData",
                "ec2:GetReservedInstancesExchangeQuote",
                "ec2:GetConsoleScreenshot",
                "ec2:GetHostReservationPurchasePreview",

                "waf-regional:Get*",
                "waf-regional:List*",

                "acm:ListCertificates",
                "iam:ListServerCertificates",

                "elasticloadbalancing:*",

                "route53:ListHostedZones",
                "route53:ListResourceRecordSets",

                "cloudwatch:PutMetricData"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
              "route53:ChangeResourceRecordSets"
            ],
            "Resource": [
              "arn:aws:route53:::hostedzone/*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "eks_work_alb_permissions" {
  role       = "${module.eks-cluster.worker_iam_role_name}"
  policy_arn = "${aws_iam_policy.eks_work_alb_permissions.arn}"
}

variable "min_num_of_workers" {
  description = "Minimum number of workers to be created on eks cluster"
  default = 5
}

variable "max_num_of_workers" {
  description = "Maximum number of workers to be created on eks cluster"
  default = 10
}
output "eks_cluster_kubeconfig" {
  description = "Working kubeconfig to talk to the eks cluster."
  value       = "${module.eks-cluster.kubeconfig}"
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = "${local.kubernetes_cluster_name}"
}
