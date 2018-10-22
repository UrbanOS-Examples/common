provider "aws" {
  version = "1.39"
  alias   = "alm"
  region  = "${var.alm_region}"

  assume_role {
    role_arn = "${var.alm_role_arn}"
  }
}

data "terraform_remote_state" "alm_remote_state" {
  backend   = "s3"
  workspace = "${var.alm_workspace}"

  config {
    bucket   = "${var.alm_state_bucket_name}"
    key      = "alm"
    region   = "us-east-2"
    role_arn = "${var.alm_role_arn}"
  }
}

resource "aws_vpc_peering_connection" "env_to_alm" {
  vpc_id        = "${module.vpc.vpc_id}"
  peer_vpc_id   = "${data.terraform_remote_state.alm_remote_state.vpc_id}"
  peer_owner_id = "${var.alm_account_id}"
  peer_region   = "${var.alm_region}"
  auto_accept   = "false"

  tags {
    Side = "Requester"
  }
}

resource "aws_vpc_peering_connection_accepter" "alm" {
  provider                  = "aws.alm"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.env_to_alm.id}"
  auto_accept               = true

  tags {
    Side = "Accepter"
  }
}

resource "aws_route" "public_peer_env_to_alm" {
  route_table_id            = "${element(module.vpc.public_route_table_ids, 0)}"
  destination_cidr_block    = "${data.terraform_remote_state.alm_remote_state.vpc_cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.env_to_alm.id}"
}

resource "aws_route" "public_peer_alm_to_env" {
  provider = "aws.alm"

  route_table_id            = "${element(data.terraform_remote_state.alm_remote_state.public_route_table_ids, 0)}"
  destination_cidr_block    = "${module.vpc.vpc_cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.env_to_alm.id}"
}

resource "aws_route" "private_peer_env_to_alm" {
  route_table_id            = "${element(module.vpc.private_route_table_ids, 0)}"
  destination_cidr_block    = "${data.terraform_remote_state.alm_remote_state.vpc_cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.env_to_alm.id}"
}

resource "aws_route" "private_peer_alm_to_env" {
  provider = "aws.alm"

  route_table_id            = "${element(data.terraform_remote_state.alm_remote_state.private_route_table_ids, 0)}"
  destination_cidr_block    = "${module.vpc.vpc_cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.env_to_alm.id}"
}

variable "alm_region" {
  description = "AWS Region of ALM Environment"
  default     = "us-east-2"
}

variable "alm_role_arn" {
  description = "The ARN for the assume role for ALM access"
  default     = "arn:aws:iam::199837183662:role/jenkins_role"
}

variable "alm_state_bucket_name" {
  description = "The name of the S3 state bucket for ALM"
  default     = "scos-alm-terraform-state"
}

variable "alm_account_id" {
  description = "Id of the account to peer to"
  default     = "199837183662"
}

variable "alm_workspace" {
  description = "Workspace for the ALM state"
  default     = "alm"
}

variable "accepter_credentials_profile" {
  description = "The AWS credentials profile to use for accepting peering"
  default     = "jenkins"
}
