module "iam_stack" {
  source              = "../modules/iam"
  vpc_id              = "${module.vpc.vpc_id}"
  subnet_ids          = ["${module.vpc.private_subnets}"]
  ssh_key             = "${aws_key_pair.cloud_key.key_name}"
  management_cidr     = "${data.terraform_remote_state.alm_remote_state.vpc_cidr_block}"
  realm_cidr          = "10.0.0.0/16"
  iam_hostname_prefix = "iam"
  zone_id             = "${aws_route53_zone.public_hosted_zone.zone_id}"
  zone_name           = "${aws_route53_zone.public_hosted_zone.name}"
  vpc_cidr            = "${local.vpc_cidr}"
}