resource "aws_db_instance" "kylo" {
  identifier                = "${terraform.workspace}-kylo"
  instance_class            = "${var.kylo_db_instance_class}"
  vpc_security_group_ids    = ["${module.eks-cluster.worker_security_group_id}"]
  db_subnet_group_name      = "${aws_db_subnet_group.default.name}"
  skip_final_snapshot       = false
  engine                    = "mysql"
  engine_version            = "${var.kylo_db_engine_version}"
  parameter_group_name      = "${aws_db_parameter_group.kylo_db_parameter_group.name}"
  allocated_storage         = "${var.kylo_db_allocated_storage}"
  storage_type              = "gp2"
  username                  = "sysadmin"
  password                  = "${random_string.kylo_db_password.result}"
  snapshot_identifier       = "${var.kylo_db_snapshot_id}"
  final_snapshot_identifier = "kylo-${sha1(timestamp())}"
  multi_az                  = "${var.kylo_db_multi_az}"
  storage_encrypted         = "${var.kylo_db_storage_encrypted}"
  name                      = "kylo"
  backup_window             = "04:54-05:24"
  backup_retention_period   = 7

  lifecycle {
    ignore_changes = ["final_snapshot_identifier", "storage_encrypted", "snapshot_identifier"]
  }

  tags {
    workload-type = "${terraform.workspace}"
  }
}

resource "aws_db_parameter_group" "kylo_db_parameter_group" {
  #Bug in kylo requiring modification of global mysql property:
  #https://kylo-io.atlassian.net/browse/KYLO-1169
  name   = "kylo-parameter-group"
  family = "mysql5.7"

  parameter {
    name  = "log_bin_trust_function_creators"
    value = "1"
  }
}

resource "random_string" "kylo_db_password" {
  length  = 40
  special = false
}

variable "kylo_db_instance_class" {
  description = "The type of the instance for the kylo database"
  default     = "db.m4.large"
}

variable "kylo_db_engine_version" {
  description = "The version of mysql used for kylo"
  default     = "5.7"
}

variable "kylo_db_allocated_storage" {
  description = "The size of the kylo database in GB"
  default     = 10
}

variable "kylo_db_storage_encrypted" {
  description = "Is kylo db encrypted"
  default     = true
}

variable "kylo_db_snapshot_id" {
  description = "The id of the kylo RDS snapshot to restore"
  default     = ""
}

variable "kylo_db_multi_az" {
  description = "is kylo rds db multi az?"
  default     = true
}

output "kylo_rds_endpoint" {
  value = "${aws_db_instance.kylo.address}:${aws_db_instance.kylo.port}"
}

output "kylo_rds_username" {
  value = "${aws_db_instance.kylo.username}"
}

output "kylo_rds_password" {
  value = "${random_string.kylo_db_password.result}"
}

output "kylo_db_instance_id" {
    value = "${aws_db_instance.kylo.id}"
}