locals {
  private_zone_name = "${terraform.workspace}.scos-internal.com"

  public_zone_id = "${data.aws_route53_zone.public_hosted_zone.zone_id}"
}

resource "aws_route53_zone" "private_hosted_zone" {
  name          = "${local.private_zone_name}"
  force_destroy = true
  vpc_id        = "${data.aws_vpc.default.id}"

  tags = {
    Environment = "${terraform.workspace}"
  }
}

data "aws_route53_zone" "public_hosted_zone" {
  name         = "smartcolumbusos.com."
  private_zone = false
}

variable "terraform_state_role_arn" {
  description = "Role ARN that allows reading of the terraform state from"
  default     = "arn:aws:iam::199837183662:role/UpdateTerraform"
}
