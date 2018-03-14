provider "aws" {
  region = "us-east-2"
}

module "vpc" {
  source = "../modules/vpc"

  name = "experiment-vpc"

  cidr = "10.0.0.0/16"

  azs                 = ["us-east-2a", "us-east-2b", "us-east-2c"]
  # subnets are evenly spread across availability zones
  # the first 3 subnets are private. The following 3 are private that are intended to be controlled via ACL. Only use them
  # if there is a real compelling reason for doing so
  private_subnets     = ["10.0.0.0/19", "10.0.64.0/19", "10.0.128.0/19"]
  protected_subnets     = ["10.0.48.0/21", "10.0.112.0/21", "10.0.176.0/21"]
  public_subnets      = ["10.0.32.0/20", "10.0.96.0/20", "10.0.160.0/20"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  enable_s3_endpoint       = true
  enable_dynamodb_endpoint = true

  tags = {
    Owner       = "jenkins"
    Environment = "experiment"
    Name        = "experiment-vpc"
  }
}
