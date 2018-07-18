locals {
  is_prod   = "${terraform.workspace == "prod" ? 1  : 0}"
  zone_name = "${local.is_prod ? var.root_dns_name : format("%s.%s", terraform.workspace, var.root_dns_name)}"
}

resource "aws_route53_zone" "public_hosted_zone" {
  name          = "${local.zone_name}"
  force_destroy = true

  tags = {
    Environment = "${terraform.workspace}"
  }
}

resource "aws_route53_zone" "private" {
  name   = "${terraform.workspace}.internal.k8s"
  vpc_id = "${module.vpc.vpc_id}"
}

module "dev_dns" {
  source                = "./modules/remote_dns/"
  remote_workspace      = "dev"
  remote_bucket_name    = "${var.alm_state_bucket_name}"
  public_hosted_zone_id = "${aws_route53_zone.public_hosted_zone.zone_id}"
  count                 = "${local.is_prod}"
}

module "staging_dns" {
  source                = "./modules/remote_dns/"
  remote_workspace      = "staging"
  remote_bucket_name    = "${var.alm_state_bucket_name}"
  public_hosted_zone_id = "${aws_route53_zone.public_hosted_zone.zone_id}"
  count                 = "${local.is_prod}"
}

module "alm_dns" {
  source                = "./modules/remote_dns/"
  remote_workspace      = "alm"
  remote_bucket_name    = "${var.alm_state_bucket_name}"
  public_hosted_zone_id = "${aws_route53_zone.public_hosted_zone.zone_id}"
  count                 = "${local.is_prod}"
}

resource "aws_route53_record" "jupyterhub_dns" {
  zone_id = "${aws_route53_zone.public_hosted_zone.zone_id}"
  name    = "jupyter"
  type    = "A"

  count = 1

  alias {
    name                   = "${aws_elb.jupyter_elb.dns_name}"
    zone_id                = "${aws_elb.jupyter_elb.zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "alm_jupyterhub_dns" {
  provider = "aws.alm"
  zone_id  = "${data.terraform_remote_state.vpc.private_zone_id}"
  name     = "jupyter"
  type     = "A"

  count = 1

  alias {
    name                   = "${aws_elb.jupyter_elb.dns_name}"
    zone_id                = "${aws_elb.jupyter_elb.zone_id}"
    evaluate_target_health = false
  }
}

variable "root_dns_name" {
  description = "Name of root domain (ex. example.com)"
}

output "name_servers" {
  value = "${aws_route53_zone.public_hosted_zone.name_servers}"
}

output "domain_zone_id" {
  value = "${aws_route53_zone.public_hosted_zone.zone_id}"
}
