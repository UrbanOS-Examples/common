provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
   bucket = "scos-terraform-state"
   key    = "vpc"
   region = "us-east-2"
   dynamodb_table="terraform_lock"
   encrypt = "true"
   role_arn = "arn:aws:iam::784801362222:role/UpdateTerraform"
 }
}

data "terraform_remote_state" "efs" {
  backend   = "s3"
  workspace = "${terraform.workspace}"

  config {
    bucket   = "scos-terraform-state"
    key      = "efs"
    region   = "us-east-2"
    role_arn = "arn:aws:iam::784801362222:role/UpdateTerraform"
  }
}

module "vpc" {
  source = "../modules/vpc"

  name = "${var.name}"

  cidr = "${var.cidr}"

  azs                 = "${var.azs}"
  # subnets are evenly spread across availability zones. Each Availability Zone has a public, private and protected subnet
  #each of the subnets are big eanough to allow future growth but in case we run out of IP's there is also a lot of spare
  #capacity that can be used e.g 10.0.172.0/18
  private_subnets     = "${var.private_subnets}"
  #protected subnets are esentially private but by convention also use NACL's to control access. Since NACLs tend to
  #become a maintenance issue it is recommended to use security groups and private subnets unless we have a compeling reason to do
  #otherwise
  protected_subnets     = "${var.protected_subnets}"
  public_subnets      = "${var.public_subnets}"

  #Note: NAT gateways cost around $400/year/instance.  If the Availability Zone that hosts the NAT gateway is down,
  #then we cannot reach the internet from Private or Protected subnets. In order to ensure High Availability we will need to
  #create multiple NAT Gateways, ideally one per Availability Zone.
  #It makes sense to have NAT Gateway per AZ in Production but maybe is not a big deal in other environments. We need to consider
  #making an exception for Management as well.

  enable_nat_gateway = "${var.enable_nat_gateway}"
  #this flag will create a single NAT gateway for the VPC otherwise there will be a NAT gateway per Availability Zone
  single_nat_gateway = "${var.single_nat_gateway}"

  enable_vpn_gateway = "${var.enable_vpn_gateway}"

  enable_s3_endpoint       = "${var.enable_s3_endpoint}"
  enable_dynamodb_endpoint = "${var.enable_dynamodb_endpoint}"

  efs_id =  "${data.terraform_remote_state.efs.efs_id}"

  tags = {
    Owner       = "${var.name}"
    Environment = "${var.environment}"
    Name        = "${var.owner}"
  }

}
