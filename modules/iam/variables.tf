locals {
    freeipa_instance_count   = 2
    iam_instance_type        = "t2.small"
    iam_instance_ami         = "ami-0d50f5c6b01e2d95d"
    tcp_ports                = "53,80,88,389,443,464,636,7389,9443,9444,9445"
    udp_ports                = "53,88,123,464"
}

variable "vpc_id" {
  description = "The output id of the vpc to host the stack"
}

variable "vpc_cidr" {
  description = "The cidr block of the parent VPC."
}

variable "subnet_ids" {
  type        = "list"
  description = "The output id of the subnet to host the stack"
}

variable "ssh_key" {
  description = "The ssh key to inject into the deployed ec2 instances"
}

variable "management_cidr" {
  description = "The cidr of the hub management vpc to allow access to the environment"
}

variable "realm_cidr" {
  description = "The cidr of the network segment that will be managed by the iam stack"
}

variable "iam_hostname_prefix" {
  description = "The name prefix of the iam server"
  default     = "iam"
}

variable "admin_password" {
  description = "The default admin password of the IPA server"
  default     = "letmeinnow"
}

variable "zone_id" {
  description = "The output id of the primary dns zone."
}

variable "zone_name" {
  description = "The name of the primary dns zone."
}

variable "keycloak_version" {
  description = "The version of Keycloak to download and install"
  default     = "4.5.0"
}
