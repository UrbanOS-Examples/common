data "aws_secretsmanager_secret_version" "bind_user_password" {
  provider = "aws.alm"

  secret_id = "${data.terraform_remote_state.alm_remote_state.bind_user_password_secret_id}"
}

module "cloudbreak" {
  source = "git@github.com:SmartColumbusOS/scos-tf-cloudbreak?ref=1.0.0"
  vpc_id                   = "${module.vpc.vpc_id}"
  subnets                  = "${local.hdp_subnets}"
  db_subnets                  = "${local.private_subnets}"
  remote_management_cidr   = "${data.terraform_remote_state.alm_remote_state.vpc_cidr_block}"
  alb_certificate          = "${module.tls_certificate.arn}"
  cloudbreak_dns_zone_id   = "${aws_route53_zone.internal_public_hosted_zone.zone_id}"
  cloudbreak_dns_zone_name = "${aws_route53_zone.internal_public_hosted_zone.name}"
  cloudbreak_tag           = "1.0.0"
  ssh_key                  = "${aws_key_pair.cloud_key.key_name}"
  skip_final_db_snapshot        = "${var.skip_final_db_snapshot}"
  recovery_window_in_days  = "${var.recovery_window_in_days}"
}

module "datalake" {
  source = "git@github.com:SmartColumbusOS/scos-tf-datalake?ref=1.0.0"

  region                         = "${var.region}"
  vpc_id                         = "${module.vpc.vpc_id}"
  subnets                        = "${local.hdp_subnets}"
  db_subnets                     = "${local.private_subnets}"
  remote_management_cidr         = "${data.terraform_remote_state.alm_remote_state.vpc_cidr_block}"
  ssh_key                        = "${aws_key_pair.cloud_key.key_name}"
  alb_certificate                = "${module.tls_certificate.arn}"
  datalake_dns_zone_id           = "${aws_route53_zone.internal_public_hosted_zone.zone_id}"
  cloudbreak_ip                  = "${module.cloudbreak.cloudbreak_instance}"
  cloudbreak_security_group      = "${module.cloudbreak.cloudbreak_security_group}"
  cloudbreak_credential_name     = "${module.cloudbreak.cloudbreak_credential_name}"
  cloudbreak_ready               = "${module.cloudbreak.cloudbreak_ready}"
  ldap_server                    = "${var.ldap_server}"
  ldap_domain                    = "${var.ldap_domain}"
  ldap_bind_password             = "${data.aws_secretsmanager_secret_version.bind_user_password.secret_string}"
  eks_worker_node_security_group = "${aws_security_group.chatter.id}"
  skip_final_db_snapshot         = "${var.skip_final_db_snapshot}"
  parent_hosted_zone_name        = "${aws_route53_zone.internal_public_hosted_zone.name}"
  parent_hosted_zone_id          = "${aws_route53_zone.internal_public_hosted_zone.id}"
  recovery_window_in_days        = "${var.recovery_window_in_days}"
  role_arn                       = "${var.role_arn}"
}

variable "ldap_server" {
  description = "The address of the ldap server"
  default     = "iam-master.alm.internal.smartcolumbusos.com"
}

variable "ldap_domain" {
  description = "The ldap domain in domain component format"
  default     = "dc=internal,dc=smartcolumbusos,dc=com"
}

output "hive_metastore_url" {
  value       = "${module.datalake.hive_metastore_url}"
}

output "hive_metastore_username" {
  value = "${module.datalake.hive_metastore_username}"
}

output "hive_metastore_password_secret_id" {
  value = "${module.datalake.hive_metastore_password_secret_id}"
}

output "hive_thrift_url" {
  value = "${module.datalake.hive_thrift_url}"
}

output "hive_thrift_username" {
  value = "${module.datalake.hive_thrift_username}"
}

output "hive_thrift_password_secret_id" {
  value = "${module.datalake.hive_thrift_password_secret_id}"
}

output "datalake_master_address_list" {
  value = "${module.datalake.master_address_list}"
}

output "ranger_db_endpoint" {
  description = "The FQDN:Port of the Ranger RDS database."
  value       = "${module.datalake.ranger_db_endpoint}"
}

output "blueprint_name" {
  description = "The name of the blueprint that is deployed for a given blueprint iteration."
  value       = "${module.datalake.blueprint_name}"
}

output "cluster_name" {
  description = "The name of the cluster resulting from a given deployment with unique value hashing."
  value       = "${module.datalake.cluster_name}"
}
