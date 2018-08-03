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
                "ec2:*",
                "elasticloadbalancing:*",
                "waf-regional:*",
                "acm:ListCertificates",
                "iam:ListServerCertificates"
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
