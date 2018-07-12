provider "aws" {
  region = "${var.region}"

  assume_role {
    role_arn = "${var.role_arn}"
  }
}

terraform {
  backend "s3" {
    bucket         = "scos-sandbox-terraform-state"
    key            = "operating-system"
    region         = "us-east-2"
    dynamodb_table = "terraform_lock"
    encrypt        = true
  }
}

resource "aws_key_pair" "cloud_key" {
  key_name   = "${terraform.workspace}_env_cloud_key"
  public_key = "${var.key_pair_public_key}"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "1.32.0"

  name = "${var.vpc_name}"
  cidr = "${var.vpc_cidr}"
  azs  = "${var.vpc_azs}"

  private_subnets = "${var.vpc_private_subnets}"
  public_subnets  = "${var.vpc_public_subnets}"

  enable_nat_gateway = "${var.vpc_enable_nat_gateway}"
  single_nat_gateway = "${var.vpc_single_nat_gateway}"

  enable_vpn_gateway       = "${var.vpc_enable_vpn_gateway}"
  enable_s3_endpoint       = "${var.vpc_enable_s3_endpoint}"
  enable_dynamodb_endpoint = "${var.vpc_enable_dynamodb_endpoint}"
  enable_dns_hostnames     = "${var.vpc_enable_dns_hostnames}"

  tags = {
    Owner                                  = "${var.owner}"
    Environment                            = "${var.environment}"
    Name                                   = "${var.vpc_name}"
    "kubernetes.io/cluster/streaming-kube" = "owned"
  }
}

resource "aws_route53_zone" "private" {
  name          = "${var.dns_zone_name}"
  vpc_id        = "${module.vpc.vpc_id}"
  force_destroy = true

  tags = {
    Environment = "${var.environment}"
  }
}

module "kubernetes" {
  source              = "github.com/SmartColumbusOS/terraform-aws-kubernetes"
  cluster_name        = "${var.kubernetes_cluster_name}"
  aws_region          = "${var.region}"
  hosted_zone         = "${aws_route53_zone.private.name}"
  hosted_zone_id      = "${aws_route53_zone.private.zone_id}"
  hosted_zone_private = true
  master_subnet_id    = "${module.vpc.private_subnets[0]}"
  worker_subnet_ids   = "${module.vpc.private_subnets}"
  min_worker_count    = "${var.min_worker_count}"
  max_worker_count    = "${var.max_worker_count}"
  ssh_public_key      = "${var.kube_key}"

  addons = [
    "https://raw.githubusercontent.com/scholzj/terraform-aws-kubernetes/master/addons/storage-class.yaml",
    "https://raw.githubusercontent.com/scholzj/terraform-aws-kubernetes/master/addons/heapster.yaml",
    "https://raw.githubusercontent.com/scholzj/terraform-aws-kubernetes/master/addons/dashboard.yaml",
    "https://raw.githubusercontent.com/scholzj/terraform-aws-kubernetes/master/addons/external-dns.yaml",
    "https://raw.githubusercontent.com/scholzj/terraform-aws-kubernetes/master/addons/autoscaler.yaml",
  ]

  tags = {
    Environmnet = "${var.environment}"
    DNSZone     = "${aws_route53_zone.private.zone_id}"
  }

  tags2 = [
    {
      key                 = "Application"
      value               = "AWS-Kubernetes"
      propagate_at_launch = true
    },
  ]
}

locals {
  jupyter_port = 30001
}

resource "aws_elb" "jupyter_elb" {
  name = "jupyter-elb"

  internal = true

  subnets         = ["${module.vpc.private_subnets}"]
  security_groups = ["${module.kubernetes.kubeconfig_security_group}"]

  listener {
    instance_port = "${local.jupyter_port}"

    instance_protocol = "HTTP"
    lb_port           = 80
    lb_protocol       = "HTTP"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:${local.jupyter_port}"
    interval            = 30
  }
}

resource "aws_autoscaling_attachment" "jupyter_k8s_attachment" {
  autoscaling_group_name = "${module.kubernetes.autoscaling_group_name}"
  elb                    = "${aws_elb.jupyter_elb.id}"
}

resource "aws_route53_record" "jupyterhub_dns" {
  zone_id = "${var.public_dns_zone_id}"
  name    = "jupyter.${var.dns_zone_name}"
  type    = "A"

  count = 1

  alias {
    name                   = "${aws_elb.jupyter_elb.dns_name}"
    zone_id                = "${aws_elb.jupyter_elb.zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_security_group_rule" "allow_inbound_traffic_from_alm" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "-1"
  cidr_blocks       = ["${data.terraform_remote_state.vpc.vpc_cidr_block}"]
  security_group_id = "${module.kubernetes.kubeconfig_security_group}"
}
