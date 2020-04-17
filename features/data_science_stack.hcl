module "parking_prediction_database" {
  source = "git@github.com:SmartColumbusOS/scos-tf-rds?ref=1.1.0"

  identifier = "${terraform.workspace}-data-science-parking-prediction"
  prefix     = "${terraform.workspace}-data-science-parking-prediction"
  type       = "sqlserver-web"
  version    = "14.00.3223.3.v1"
  port       = "1433"
  username   = "padmin"

  multi_az                 = false
  attached_vpc_id          = "${module.vpc.vpc_id}"
  attached_subnet_ids      = "${local.private_subnets}"
  attached_security_groups = ["${aws_security_group.chatter.id}"]
  instance_class           = "db.m5.xlarge"
}
