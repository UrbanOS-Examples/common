locals {
  ambari_blueprint_path    = "${path.module}/templates/datalake-ambari-blueprint.json.tpl"
  ambari_blueprint_sha     = "${substr(sha1(file(local.ambari_blueprint_path)), 0, 12)}"
  deployment_template_sha  = "${substr(sha1(data.template_file.cloudbreak_cluster.rendered), 0, 12)}"
  hive_db_name             = "hive"            // at present we don't trigger updates based on RDS changes
  ranger_db_name           = "ranger"
  ldap_connection_name     = "ldap"
  ambari_blueprint_name    = "SCOS DataLake ${local.ambari_blueprint_sha}"
  ambari_gateway_path      = "scos-datalake"
  ambari_username          = "admin"
  cluster_subnet           = "${random_shuffle.private_subnet.result[0]}"
  cluster_name             = "hdp-${local.deployment_template_sha}"
  ensure_db_path           = "${path.module}/templates/ensure_databases.sh"
  ensure_cluster_path      = "${path.module}/templates/ensure_cluster.sh"
  ensure_blueprint_path    = "${path.module}/templates/ensure_blueprint.sh"
  ensure_ldap_path         = "${path.module}/templates/ensure_ldap.sh"
}

variable "vpc_id" {
  description = "The VPC to deploy the datalake into."
}

variable "region" {
  description = "The Region into which to deploy the HDP cluster."
}

variable "subnets" {
  description = "List of subnets to deploy the datalake into."
  type        = "list"
}

variable "remote_management_cidr" {
  description = "CIDR block of the ALM network."
}

variable "ssh_key" {
  description = "The SSH key to inject into the cloudbreak instance."
}

variable "cloud_storage_bucket_prefix" {
  description = "The name of the s3 bucket to use for the hdfs cloud storage"
  default     = "scos-hdfs"
}

variable "cloudbreak_credential_name" {
  description = "The name of the IAM credential to attach to the deployed cluster."
}

variable "cloudbreak_ip" {
  description = "The IP address of the cloudbreak server from which to execute deployments."
}

variable "cloudbreak_ready" {
  description = "The cloudbreak readiness state, so we can depend on it"
}

variable "datalake_dns_zone_id" {
  description = "The DNS Zone for the datalake hostname"
}

variable "alb_certificate" {
  description = "The certificate for TLS on the datalake"
}

variable "hive_db_multi_az" {
  description = "Should the Hive DB be multi-az?"
  default     = true
}

variable "ranger_db_multi_az" {
  description = "Should the Ranger DB be multi-az?"
  default     = true
}

variable "hive_db_apply_immediately" {
  description = "Should changes to the Hive DB be applied immediately?"
  default     = false
}

variable "ranger_db_apply_immediately" {
  description = "Should changes to the Ranger DB be applied immediately?"
  default     = false
}

variable "cloudbreak_security_group" {
  description = "The id of the security group wrapping the cloudbreak server."
}


variable "mgmt_group_instance_type" {
  description = "EC2 flavor to deploy the management hostgroup cluster nodes."
  default     = "t2.large"
}

variable "master_group_instance_type" {
  description = "EC2 flavor to deploy the master hostgroups cluster nodes."
  default     = "m5.2xlarge"
}

variable "worker_group_instance_type" {
  description = "EC2 flavor to deploy the worker hostgroup cluster nodes."
  default     = "m5.2xlarge"
}

variable "broker_group_instance_type" {
  description = "EC2 flavor to deploy the broker hostgroup cluster nodes."
  default     = "m5.large"
}

variable "worker_node_count" {
  description = "Number of worker nodes to include in the cluster."
  default     = 1
}

variable "broker_node_count" {
  description = "Number of broker (zookeeper) nodes to include in the cluster."
  default     = 1
}

variable "eks_worker_node_security_group" {
  description = "Security group for the EKS worker nodes"
}
variable "ldap_server" {
  description = "The address of the ldap server"
}

variable "ldap_port" {
  description = "The port on which to connect to ldap"
  default     = 389
}

variable "ldap_domain" {
  description = "The ldap domain in domain component format"
}

variable "ldap_bind_user" {
  description = "The non-privileged ldap user for directory integration"
  default     = "binduser"
}

variable "ldap_bind_password" {
  description = "Password for the non-privileged ldap bind user"
}

variable "ldap_admin_group" {
  description = "The group that will administer the hdp cluster"
  default     = "hadoop"
}
