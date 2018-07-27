provider "aws" {
  region = "${var.region}"

  assume_role {
    role_arn = "${var.role_arn}"
  }
}

terraform {
  backend "s3" {
    key     = "operating-system"
    encrypt = true
  }
}

resource "aws_key_pair" "cloud_key" {
  key_name   = "${terraform.workspace}_env_cloud_key"
  public_key = "${var.key_pair_public_key}"
}

resource "aws_security_group_rule" "allow_inbound_traffic_from_alm" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "-1"
  cidr_blocks       = ["${data.terraform_remote_state.alm_remote_state.vpc_cidr_block}"]
  security_group_id = "${module.kubernetes.kubeconfig_security_group}"
}

variable "region" {
  description = "AWS Region"
  default     = "us-west-2"
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
