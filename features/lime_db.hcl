module "lime_db" {
  source = "git@github.com:SmartColumbusOS/scos-tf-rds?ref=2.1.0"

  prefix        = "${terraform.workspace}-lime"
  identifier    = "${terraform.workspace}-lime"
  database_name = "lime_survey"
  type          = "postgres"
  vers          = "10.15"

  attached_vpc_id          = module.vpc.vpc_id
  attached_subnet_ids      = local.private_subnets
  attached_security_groups = [aws_security_group.chatter.id]
  instance_class           = "db.t2.small"
}

output "lime_db_address" {
  value = module.lime_db.address
}

output "lime_db_port" {
  value = module.lime_db.port
}

output "lime_db_password_id" {
  value = module.lime_db.password_secret_id
}

