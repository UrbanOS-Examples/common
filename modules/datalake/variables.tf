locals {
  ambari_blueprint_path    = "${path.module}/templates/datalake-ambari-blueprint.json"
  ambari_blueprint_sha     = "${substr(sha1(file(local.ambari_blueprint_path)), 0, 12)}"
  deployment_template_sha  = "${substr(sha1(data.template_file.cloudbreak_cluster.rendered), 0, 12)}"
  cb_credential_name       = "cb-credential"   // at present we don't trigger updates based on IAM changes
  hive_db_name             = "hive"            // at present we don't trigger updates based on RDS changes
  ambari_blueprint_name    = "SCOS DataLake ${local.ambari_blueprint_sha}"
  ambari_gateway_path      = "scos-datalake"
  ambari_username          = "admin"
  cluster_subnet           = "${random_shuffle.private_subnet.result[0]}"
  cluster_name             = "hdp-${local.deployment_template_sha}"

  start_cloudbreak_path   = "${path.module}/templates/start_cloudbreak.sh"
  update_hive_path        = "${path.module}/templates/update_hive_db.sh"
  update_credentials_path = "${path.module}/templates/update_credentials.sh"
  create_cluster_path     = "${path.module}/templates/create_cluster.sh"
  create_blueprint_path   = "${path.module}/templates/create_blueprint.sh"
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

variable "alb_certificate" {
  description = "ALB certificate to attach to the Cloudbreak load balancer."
}

variable "cloudbreak_dns_zone_id" {
  description = "DNS public zone to create the cloudbreak A record."
}

variable "cloudbreak_dns_zone_name" {
  description = "Name of the DNS public zone"
}

variable "cloudbreak_db_multi_az" {
  description = "Should the Cloudbreak DB be multi-az?"
  default     = true
}

variable "cloudbreak_db_apply_immediately" {
  description = "Should changes to the Cloudbreak DB be applied immediately?"
  default     = false
}

variable "ssh_key" {
  description = "The SSH key to inject into the cloudbreak instance."
}

variable "cloudbreak_version" {
  description = "The version of Cloudbreak to pack into the AMI."
  default     = "2.7.1"
}

variable "cloudbreak_tag" {
  description = "The released version of a Cloudbreak AMI to use"
  default     = "1.0.0"
}

variable "hive_db_multi_az" {
  description = "Should the Hive DB be multi-az?"
  default     = true
}

variable "hive_db_apply_immediately" {
  description = "Should changes to the Hive DB be applied immediately?"
  default     = false
}

variable "worker_node_count" {
  description = "Number of worker nodes to include in the cluster."
  default     = 1
}

variable "broker_node_count" {
  description = "Number of broker (zookeeper) nodes to include in the cluster."
  default     = 1
}
