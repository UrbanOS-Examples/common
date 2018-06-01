provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    bucket         = "scos-alm-terraform-state"
    key            = "operating-system"
    region         = "us-east-2"
    dynamodb_table = "terraform_lock"
    encrypt        = true
  }
}

resource "aws_key_pair" "cloud_key" {
  key_name   = "${terraform.workspace}_cloud_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDRAvH6k7iEeRDz9SQtkH1o8KiUaed/e2hmzTUjA8bhmeWVLPsgCMKIUKR0jdPlvdZ0AmMLXswobsXj08dPgWxUZxoAWIqKCjd969KckydUpBtcb+X2Q+tpOcugBOQSY1H8hgNrdcRKEaUllTfvseJ9pBOYU7j9VuZ608HQhfZw7+aS8wi9o/BJwejtpWdlo6gkxXoIRqDX/ioYg+W6Tc7yoUzAEANwZAy3/3GKWDrh+9jnzR6mEEN48Nuee49wWfP5G0T/v4+Gvux5zioHb3rcmmR9YTkFOiv1poInhXlPdc7Q38yj+z6E+hACNN3rK80YjU0ByaSPltPjqm9ZYmPX"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "1.32.0"

  name = "${var.vpc_name}"
  cidr = "${var.vpc_cidr}"
  azs  = "${var.vpc_azs}"

  private_subnets = "${var.vpc_private_subnets}"
  public_subnets  = "${var.vpc_public_subnets}"

  enable_nat_gateway = "${var.vpc_enable_nat_gateway}"
  single_nat_gateway = "${var.vpc_single_nat_gateway}"

  enable_vpn_gateway       = "${var.vpc_enable_vpn_gateway}"
  enable_s3_endpoint       = "${var.vpc_enable_s3_endpoint}"
  enable_dynamodb_endpoint = "${var.vpc_enable_dynamodb_endpoint}"
  enable_dns_hostnames     = "${var.vpc_enable_dns_hostnames}"

  tags = {
    Owner       = "${var.owner}"
    Environment = "${var.environment}"
    Name        = "${var.vpc_name}"
  }
}

resource "aws_vpc_peering_connetion" "env_to_alm" {
	vpc_id = "${module.vpc.vpc_id}"
	peer_vpc_id = "${data.<something>.vpc.vpc_id}"
	peer_owner_id = "${var.other_subaccount_id}"
	peer_region = "${var.region}"
  auto_accept = "false"

	tags {
		Side = "Requester"
  }
}

resource "aws_vpc_peering_connection_accepter" "alm" {
	provider = "aws.alm"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.env_to_alm.id}"
	auto_accept = true

	tags {
		Side = "Accepter"
	}
}

resource "aws_route53_zone" "private" {
  name          = "${var.private_dns_zone_name}"
  vpc_id        = "${module.vpc.vpc_id}"
  force_destroy = true

  tags = {
    Environment = "${var.environment}"
  }
}

module "kubernetes" {
  source  = "scholzj/kubernetes/aws"
  version = "1.3.3"

  cluster_name = "jd-cluster-name" # FIXME
  aws_region   = "${var.region}"

  hosted_zone         = "${aws_route53_zone.private.name}"
  hosted_zone_private = true

  master_subnet_id  = "${module.vpc.public_subnets[0]}"
  worker_subnet_ids = "${module.vpc.public_subnets}"

  min_worker_count = 2
  max_worker_count = 3

  addons = [
    "https://raw.githubusercontent.com/scholzj/terraform-aws-kubernetes/master/addons/storage-class.yaml",
    "https://raw.githubusercontent.com/scholzj/terraform-aws-kubernetes/master/addons/heapster.yaml",
    "https://raw.githubusercontent.com/scholzj/terraform-aws-kubernetes/master/addons/dashboard.yaml",
    "https://raw.githubusercontent.com/scholzj/terraform-aws-kubernetes/master/addons/external-dns.yaml",
    "https://raw.githubusercontent.com/scholzj/terraform-aws-kubernetes/master/addons/autoscaler.yaml"
  ]

  tags = {
    Environmnet = "${var.environment}"
		DNSZone = "${aws_route53_zone.private.zone_id}"
  }

  tags2 = [
    {
      key = "Application"
      value = "AWS-Kubernetes"
      propagate_at_launch = true
    }
  ]
}
