provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    bucket         = "scos-alm-terraform-state"
    key            = "vpc"
    region         = "us-east-2"
    dynamodb_table = "terraform_lock"
    encrypt        = "true"
  }
}

data "aws_secretsmanager_secret_version" "openvpn_admin_password" {
  secret_id = "${var.openvpn_admin_password_secret_arn}"
}

resource "aws_key_pair" "cloud_key" {
  key_name   = "cloud_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDRAvH6k7iEeRDz9SQtkH1o8KiUaed/e2hmzTUjA8bhmeWVLPsgCMKIUKR0jdPlvdZ0AmMLXswobsXj08dPgWxUZxoAWIqKCjd969KckydUpBtcb+X2Q+tpOcugBOQSY1H8hgNrdcRKEaUllTfvseJ9pBOYU7j9VuZ608HQhfZw7+aS8wi9o/BJwejtpWdlo6gkxXoIRqDX/ioYg+W6Tc7yoUzAEANwZAy3/3GKWDrh+9jnzR6mEEN48Nuee49wWfP5G0T/v4+Gvux5zioHb3rcmmR9YTkFOiv1poInhXlPdc7Q38yj+z6E+hACNN3rK80YjU0ByaSPltPjqm9ZYmPX"
}

module "vpc" {
  source = "../modules/vpc"

  name = "${var.name}"

  cidr = "${var.cidr}"

  azs = "${var.azs}"

  # subnets are evenly spread across availability zones. Each Availability Zone has a public, private and protected subnet
  #each of the subnets are big eanough to allow future growth but in case we run out of IP's there is also a lot of spare
  #capacity that can be used e.g 10.0.172.0/18
  private_subnets = "${var.private_subnets}"

  #protected subnets are esentially private but by convention also use NACL's to control access. Since NACLs tend to
  #become a maintenance issue it is recommended to use security groups and private subnets unless we have a compeling reason to do
  #otherwise
  protected_subnets = "${var.protected_subnets}"

  public_subnets = "${var.public_subnets}"

  #Note: NAT gateways cost around $400/year/instance.  If the Availability Zone that hosts the NAT gateway is down,
  #then we cannot reach the internet from Private or Protected subnets. In order to ensure High Availability we will need to
  #create multiple NAT Gateways, ideally one per Availability Zone.
  #It makes sense to have NAT Gateway per AZ in Production but maybe is not a big deal in other environments. We need to consider
  #making an exception for Management as well.

  enable_nat_gateway = "${var.enable_nat_gateway}"
  #this flag will create a single NAT gateway for the VPC otherwise there will be a NAT gateway per Availability Zone
  single_nat_gateway       = "${var.single_nat_gateway}"
  enable_vpn_gateway       = "${var.enable_vpn_gateway}"
  enable_s3_endpoint       = "${var.enable_s3_endpoint}"
  enable_dynamodb_endpoint = "${var.enable_dynamodb_endpoint}"
  enable_dns_hostnames     = "${var.enable_dns_hostnames}"
  tags = {
    Owner       = "${var.name}"
    Environment = "${var.environment}"
    Name        = "${var.owner}"
  }
}

module "vpn" {
  source = "../modules/vpn"

  private_subnet_id = "${module.vpc.private_subnets[0]}"
  public_subnet_id  = "${module.vpc.public_subnets[0]}"
  vpc_id            = "${module.vpc.vpc_id}"
  admin_user        = "${var.openvpn_admin_username}"
  admin_password    = "${data.aws_secretsmanager_secret_version.openvpn_admin_password.secret_string}"
  key_name          = "${aws_key_pair.cloud_key.key_name}"
}
