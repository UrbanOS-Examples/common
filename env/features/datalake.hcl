module "datalake" {
  source = "../modules/datalake"

  region                     = "${var.region}"
  vpc_id                     = "${module.vpc.vpc_id}"
  subnets                    = "${module.vpc.private_subnets}"
  remote_management_cidr     = "${data.terraform_remote_state.alm_remote_state.vpc_cidr_block}"
  ssh_key                    = "${aws_key_pair.cloud_key.key_name}"
  alb_certificate            = "${module.tls_certificate.arn}"
  datalake_dns_zone_id       = "${aws_route53_zone.public_hosted_zone.zone_id}"
  cloudbreak_ip              = "${module.cloudbreak.cloudbreak_instance}"
  cloudbreak_security_group  = "${module.cloudbreak.cloudbreak_security_group}"
  cloudbreak_credential_name = "${module.cloudbreak.cloudbreak_credential_name}"
  cloudbreak_ready           = "${module.cloudbreak.cloudbreak_ready}"
  ldap_server                = "${var.ldap_server}"
  ldap_domain                = "${var.ldap_domain}"
  ldap_bind_password         = "${var.ldap_bind_password}"
}

variable "ldap_server" {
  description = "The address of the ldap server"
  default     = "iam-master.alm.internal.smartcolumbusos.com"
}

variable "ldap_domain" {
  description = "The ldap domain in domain component format"
  default     = "dc=internal,dc=smartcolumbusos,dc=com"
}

variable "ldap_bind_password" {
  description = "Password for the non-privileged ldap bind user"
  default     = "foobarbilly79"
}
