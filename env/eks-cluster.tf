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

output "eks-cluster-kubeconfig" {
  description = "Working kubeconfig to talk to the eks cluster."
  value       = "${module.eks-cluster.kubeconfig}"
}
