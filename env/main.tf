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
    role_arn       = "arn:aws:iam::068920858268:role/admin_role"
    dynamodb_table = "terraform_lock_sandbox"
    encrypt        = true
  }
}

resource "aws_key_pair" "cloud_key" {
  key_name   = "${terraform.workspace}_env_cloud_key"
  public_key = "${var.key_pair_public_key}"
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

locals {
  jupyter_port = 30001
}

variable "region" {
  description = "AWS Region"
  default     = "us-east-2"
}

variable "environment" {
  description = "VPC environment. It can be sandbox, dev, staging or production"
  default     = ""
}

variable "public_dns_zone_id" {
  description = "Public DNS zone ID"
}

variable "role_arn" {
  description = "The ARN for the assumed role into the environment to be changes (e.g. dev, test, prod)"
}

output "key_pair_name" {
  description = "Name of the keypair to use for env deployments"
  value       = "${aws_key_pair.cloud_key.key_name}"
}
