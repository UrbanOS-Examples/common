module "lime_db" {
  source = "../modules/lime_db"

  vpc_id  = "${module.vpc.vpc_id}"
  subnets = "${module.vpc.private_subnets}"
}

output "lime_db_address" {
  value = "${module.lime_db.lime_db_address}"
}

output "lime_db_port" {
  value = "${module.lime_db.lime_db_port}"
}

output "lime_db_password_id" {
  value = "${module.lime_db.lime_db_password_id}"
}
