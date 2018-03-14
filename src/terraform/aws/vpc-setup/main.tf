provider "aws" {
  region = "us-east-2"
}

module "vpc" {
  source = "../modules/vpc"

  name = "experiment-vpc"

  cidr = "10.0.0.0/16"

  azs                 = ["us-east-2a", "us-east-2b", "us-east-2c"]
  # subnets are evenly spread across availability zones. Each Availability Zone has a public, private and protected subnet
  #each of the subnets are big eanough to allow future growth but in case we run out of IP's there is also a lot of spare
  #capacity that can be used e.g 10.0.172.0/18
  private_subnets     = ["10.0.0.0/19", "10.0.64.0/19", "10.0.128.0/19"]
  #protected subnets are esentially private but by convention also use NACL's to control access. Since NACLs tend to
  #become a maintenance issue it is recommended to use security groups and private subnets unless we have a compeling reason to do
  #otherwise
  protected_subnets     = ["10.0.48.0/21", "10.0.112.0/21", "10.0.176.0/21"]
  public_subnets      = ["10.0.32.0/20", "10.0.96.0/20", "10.0.160.0/20"]

  #Note: NAT gateways cost around $400/year/instance.  If the Availability Zone that hosts the NAT gateway is down,
  #then we cannot reach the internet from Private or Protected subnets. In order to ensure High Availability we will need to
  #create multiple NAT Gateways, ideally one per Availability Zone.
  #It makes sense to have NAT Gateway per AZ in Production but maybe is not a big deal in other environments. We need to consider
  #making an exception for Management as well.

  enable_nat_gateway = true
  #this flag will create a single NAT gateway for the VPC otherwise there will be a NAT gateway per Availability Zone
  single_nat_gateway = true

  enable_vpn_gateway = true

  enable_s3_endpoint       = true
  enable_dynamodb_endpoint = true

  tags = {
    Owner       = "jenkins"
    Environment = "experiment"
    Name        = "experiment-vpc"
  }
}
