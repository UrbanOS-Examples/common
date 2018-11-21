data "external" "seeded_random" {
  program = [
    "python",
    "-c",
    "import random; import json; random.seed('${terraform.workspace}'); print(json.dumps({'cidr_block': '10.{}.0.0/16'.format(random.randint(0, 255))}))"
  ]
}

locals {
  vpc_cidr = "${length(var.vpc_cidr) > 0 ? var.vpc_cidr : data.external.seeded_random.result.cidr_block}"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "1.32.0"

  name = "${local.vpc_name}"
  cidr = "${local.vpc_cidr}"
  azs  = "${var.vpc_azs}"

  private_subnets = [
    "${cidrsubnet(local.vpc_cidr, 3, 0)}",
    "${cidrsubnet(local.vpc_cidr, 3, 2)}",
    "${cidrsubnet(local.vpc_cidr, 3, 4)}",
  ]
  public_subnets  = [
    "${cidrsubnet(local.vpc_cidr, 4, 2)}",
    "${cidrsubnet(local.vpc_cidr, 4, 6)}",
    "${cidrsubnet(local.vpc_cidr, 4, 10)}",
  ]

  enable_nat_gateway = "${var.vpc_enable_nat_gateway}"
  single_nat_gateway = "${var.vpc_single_nat_gateway}"

  enable_vpn_gateway       = "${var.vpc_enable_vpn_gateway}"
  enable_s3_endpoint       = "${var.vpc_enable_s3_endpoint}"
  enable_dynamodb_endpoint = "${var.vpc_enable_dynamodb_endpoint}"
  enable_dns_hostnames     = "${var.vpc_enable_dns_hostnames}"

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = ""
    "kubernetes.io/role/alb-ingress"  = ""
  }

  tags = {
    Owner                                                    = "${var.owner}"
    Environment                                              = "${terraform.workspace}"
    Name                                                     = "${local.vpc_name}"
    "kubernetes.io/cluster/${local.kubernetes_cluster_name}" = "shared"
  }
}

resource "aws_db_subnet_group" "default" {
  name        = "environment db ${terraform.workspace} subnet group"
  description = "DB Subnet Group"
  subnet_ids  = ["${module.vpc.private_subnets}"]

  tags {
    Name = "Subnet Group for Environment ${terraform.workspace} VPC"
  }
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  default     = ""
}

variable "vpc_azs" {
  description = "A list of availability zones in the region"
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "vpc_single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  default     = true
}

variable "vpc_enable_nat_gateway" {
  description = "Provision NAT Gateways for each of your availability zones"
  default     = true
}

variable "vpc_enable_vpn_gateway" {
  description = "Should be true if you want to create a new VPN Gateway resource and attach it to the VPC"
  default     = true
}

variable "vpc_enable_s3_endpoint" {
  description = "Should be true if you want to provision an S3 endpoint to the VPC"
  default     = true
}

variable "vpc_enable_dynamodb_endpoint" {
  description = "Should be true if you want to provision a DynamoDB endpoint to the VPC"
  default     = true
}

variable "vpc_enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  default     = true
}

variable "owner" {
  description = "User creating this VPC. It should be done through jenkins"
  default     = "jenkins"
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = "${module.vpc.vpc_id}"
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = ["${module.vpc.private_subnets}"]
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = ["${module.vpc.public_subnets}"]
}

output "nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = ["${module.vpc.nat_public_ips}"]
}

variable "key_pair_public_key" {
  description = "The public key used to create a key pair"
  # The Jenkins public key
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDZUiqcbO+5rkKXuYxBcUGtyLWtNainCjKaKaV4ZBEDhUZIxSJXLNq0SH7NxcODYDNNREqUdy6okJMP16NLuMHngmZYGW7FWaB5AVeKpYOdUHL2ik+RH0pY6PquGNWXMqUP+uVB8Kn5SgqsYT/u84Re6m0FztqVf7N8L5SuDbdnkvfLUc+R3JiMArvVGGKj5GkcUAqMFuzEuBQ2e7ID/bSevtMKfrPlOCLVSUzbMIVPCrxE7YyhTDgZjN7kMNZePWQhdyq86QzHJr50qa0fMnp2oUP1qwzbFjymYbG+oXPcj9dSiB7q2anf2imBnWP8JlhSinzJZrR2wa7Vn535MBhD"
}

output "allow_all_security_group" {
  description = "Security group id to allow all traffic to access albs"
  value       = "${aws_security_group.allow_all.id}"
}
