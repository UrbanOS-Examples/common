provider "aws" {
  region = "${var.region}"

  assume_role {
    role_arn = "${var.role_arn}"
  }
}

terraform {
  backend "s3" {
    key     = "prod"
    encrypt = true
  }
}

data "terraform_remote_state" "env_remote_state" {
  backend   = "s3"
  workspace = "${terraform.workspace}"

  config {
    bucket   = "${var.alm_state_bucket_name}"
    key      = "operating-system"
    region   = "us-east-2"
    role_arn = "${var.alm_role_arn}"
  }
}

module "tls_certificate" {
  source = "github.com/azavea/terraform-aws-acm-certificate?ref=0.1.0"

  domain_name               = "${var.hosted_zone_name}"
  subject_alternative_names = ["*.${var.hosted_zone_name}"]
  hosted_zone_id            = "${var.hosted_zone_id}"
  validation_record_ttl     = "60"
}

resource "aws_security_group" "external_access" {
  name   = "SCOS External Access"
  vpc_id = "${data.terraform_remote_state.env_remote_state.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

module "load_balancer_public" {
  source              = "../modules/old_prod_load_balancer"
  target_group_prefix = "${terraform.workspace}"
  vpc_id              = "${data.terraform_remote_state.env_remote_state.vpc_id}"
  certificate_arn     = "${module.tls_certificate.arn}"
  security_group_ids  = ["${data.terraform_remote_state.env_remote_state.os_servers_sg_id}", "${aws_security_group.external_access.id}"]
  subnet_ids          = "${data.terraform_remote_state.env_remote_state.public_subnets}"
  is_external         = true
  dns_zone            = "${var.hosted_zone_name}"
}

resource "aws_lb_target_group_attachment" "joomla_public" {
  target_group_arn = "${module.load_balancer_public.target_group_arns["${terraform.workspace}-Joomla"]}"
  target_id        = "${data.terraform_remote_state.env_remote_state.joomla_instance_id}"
  port             = 80
}

resource "aws_alb_target_group_attachment" "ckan_external" {
  target_group_arn = "${module.load_balancer_public.target_group_arns["${terraform.workspace}-CKAN"]}"
  target_id        = "${data.terraform_remote_state.env_remote_state.ckan_external_instance_id}"
  port             = 80
}

resource "aws_alb_target_group_attachment" "kong_public" {
  target_group_arn = "${module.load_balancer_public.target_group_arns["${terraform.workspace}-Kong"]}"
  target_id        = "${data.terraform_remote_state.env_remote_state.kong_instance_id}"
  port             = 80
}

variable "region" {
  description = "AWS Region"
  default     = "us-west-2"
}

variable "role_arn" {
  description = "The ARN for the assumed role into the environment to be changes (e.g. dev, test, prod)"
}

variable "alm_role_arn" {
  description = "The ARN for the assume role for ALM access"
  default     = "arn:aws:iam::199837183662:role/jenkins_role"
}

variable "alm_state_bucket_name" {
  description = "The name of the S3 state bucket for ALM"
  default     = "scos-alm-terraform-state"
}

variable "alm_workspace" {
  description = "Workspace for the ALM state"
  default     = "alm"
}

variable "hosted_zone_id" {
  description = "The hosted zone id of smartcolumbusos.com"
  default     = "ZE5NAJ4YWJFBA"
}

variable "hosted_zone_name" {
  description = "The name of the hosted zone (smartcolumbusos.com)"
  default     = "smartcolumbusos.com"
}

output "tls_certificate_arn" {
  description = "ARN of the generated TLS certificate for the environment."
  value = "${module.tls_certificate.arn}"
}