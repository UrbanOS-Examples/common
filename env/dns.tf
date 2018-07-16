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

variable "region" {
  description = "AWS Region"
  default     = "us-east-2"
}

variable "role_arn" {
  description = "The ARN for the assumed role into the environment to be changes (e.g. dev, test, prod)"
  default     = "arn:aws:iam::068920858268:role/admin_role"
}

variable "environment" {
  description = "VPC environment. It can be sandbox, dev, staging or production"
}

locals {
  is_prod   = "${var.environment == "prod" ? 1  : 0}"
  zone_name = "${local.is_prod ? var.root_dns_name : format("%s.%s", var.environment, var.root_dns_name)}"
}

resource "aws_route53_zone" "public_hosted_zone" {
  name          = "${local.zone_name}"
  force_destroy = true

  tags = {
    Environment = "${var.environment}"
  }
}

data "terraform_remote_state" "sandbox-operating-system" {
  backend   = "s3"
  workspace = "sandbox"

  config {
    bucket   = "scos-sandbox-terraform-state"
    key      = "operating-system"
    region   = "us-east-2"
    role_arn = "arn:aws:iam::068920858268:role/admin_role"
    encrypt  = true
  }
}

resource "aws_route53_record" "sandbox" {
  zone_id    = "${aws_route53_zone.public_hosted_zone.zone_id}"
  name       = "sandbox"
  type       = "NS"
  records    = ["${data.terraform_remote_state.sandbox-operating-system.name_servers}"]
  ttl        = 300
  count      = "${local.is_prod}"
  depends_on = ["aws_route53_zone.public_hosted_zone"]
}

data "terraform_remote_state" "dev-operating-system" {
  backend   = "s3"
  workspace = "dev"

  config {
    bucket   = "scos-sandbox-terraform-state"
    key      = "operating-system"
    region   = "us-east-2"
    role_arn = "arn:aws:iam::068920858268:role/admin_role"
    encrypt  = true
  }
}

resource "aws_route53_record" "dev" {
  zone_id    = "${aws_route53_zone.public_hosted_zone.zone_id}"
  name       = "dev"
  type       = "NS"
  records    = ["${data.terraform_remote_state.dev-operating-system.name_servers}"]
  ttl        = 300
  count      = "${local.is_prod}"
  depends_on = ["aws_route53_zone.public_hosted_zone"]
}

data "terraform_remote_state" "staging-operating-system" {
  backend   = "s3"
  workspace = "staging"

  config {
    bucket   = "scos-sandbox-terraform-state"
    key      = "operating-system"
    region   = "us-east-2"
    role_arn = "arn:aws:iam::068920858268:role/admin_role"
    encrypt  = true
  }
}

resource "aws_route53_record" "staging" {
  zone_id    = "${aws_route53_zone.public_hosted_zone.zone_id}"
  name       = "staging"
  type       = "NS"
  records    = ["${data.terraform_remote_state.staging-operating-system.name_servers}"]
  ttl        = 300
  count      = "${local.is_prod}"
  depends_on = ["aws_route53_zone.public_hosted_zone"]
}

output "name_servers" {
  value = "${aws_route53_zone.public_hosted_zone.name_servers}"
}

output "domain_zone_id" {
  value = "${aws_route53_zone.public_hosted_zone.zone_id}"
}
