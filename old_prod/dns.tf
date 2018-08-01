locals {
  internal_zone_name = "${terraform.workspace}.scos-internal.com"

  external_zone_id = "${data.terraform_remote_state.env_remote_state.domain_zone_id}"
}

resource "aws_route53_zone" "private_hosted_zone" {
  name          = "${local.internal_zone_name}"
  force_destroy = true
  vpc_id        = "${data.aws_vpc.default.id}"

  tags = {
    Environment = "${terraform.workspace}"
  }
}

data "terraform_remote_state" "env_remote_state" {
  backend   = "s3"
  workspace = "${terraform.workspace}"

  config {
    bucket = "scos-alm-terraform-state"
    key    = "operating-system"
    region = "us-east-2"

    role_arn = "${var.terraform_state_role_arn}"
    encrypt  = true
  }
}

variable "terraform_state_role_arn" {
  description = "Role ARN that allows reading of the terraform state from"
  default     = "arn:aws:iam::199837183662:role/UpdateTerraform"
}
