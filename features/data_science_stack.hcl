module "parking_prediction_database" {
  source = "git@github.com:SmartColumbusOS/scos-tf-rds?ref=1.2.0"

  identifier = "${terraform.workspace}-data-science-parking-prediction"
  prefix     = "${terraform.workspace}-data-science-parking-prediction"
  type       = "sqlserver-web"
  version    = "14.00.3223.3.v1"
  port       = "1433"
  username   = "padmin"

  multi_az                 = false
  attached_vpc_id          = "${module.vpc.vpc_id}"
  attached_subnet_ids      = "${local.private_subnets}"
  attached_security_groups = ["${aws_security_group.chatter.id}","${aws_security_group.database_vpn_access.id}"]
  instance_class           = "db.m5.xlarge"
  allocated_storage        = 1000
}

resource "aws_security_group" "database_vpn_access" {
  name        = "database_vpn_access"
  description = "Security to allow direct connection to the data science database via the vpn"
  vpc_id      = "${module.vpc.vpc_id}"

  tags = {
    Name = "Ingress for the data science RDS."
  }

  ingress {
    description = "Allow VPN access."
    from_port   = 1433
    to_port     = 1433
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
}