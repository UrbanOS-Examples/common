module "lime_db" {
  source = "git@github.com:SmartColumbusOS/scos-tf-lime-db"

  app_compute_security_group = "${aws_security_group.chatter.id}"
  vpc_id                     = "${module.vpc.vpc_id}"
  subnets                    = "${local.private_subnets}"
  lime_db_size               = "${var.lime_db_size}"
  lime_db_storage            = "${var.lime_db_storage}"
  lime_db_multi_az           = "${var.lime_db_multi_az}"
  lime_db_apply_immediately  = "${var.lime_db_apply_immediately}"
  skip_final_db_snapshot     = "${var.skip_final_db_snapshot}"
  recovery_window_in_days    = "${var.recovery_window_in_days}"
}

variable "lime_db_size" {
  description = "The ec2 instance size of the rds instance."
}

variable "lime_db_storage" {
  description = "The volume in gigabytes to attach to the rds instance."
}

variable "lime_db_multi_az" {
  description = "Whether or not to distribute the db across azs."
}

variable "lime_db_apply_immediately" {
  description = "Whether or not to apply code changes to the db immediately (vs. waiting for maint. window)"
}

variable "lime_secret_recovery_window" {
  description = "How long to allow secrets to be recovered if they are deleted"
  default = 0
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
