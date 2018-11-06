
resource "aws_db_instance" "kylo" {
  identifier                = "${terraform.workspace}-kylo"
  instance_class            = "${var.kylo_db_instance_class}"
  vpc_security_group_ids    = ["${aws_security_group.os_servers.id}"]
  db_subnet_group_name      = "${aws_db_subnet_group.default.name}"
  skip_final_snapshot       = false
  engine                    = "mysql"
  engine_version            = "${var.kylo_db_engine_version}"
  parameter_group_name      = "${var.kylo_db_parameter_group_name}"
  allocated_storage         = "${var.kylo_db_allocated_storage}"
  storage_type              = "gp2"
  username                  = "sysadmin"
  password                  = "${random_string.kylo_db_password.result}"
  snapshot_identifier       = "${var.kylo_db_snapshot_id}"
  final_snapshot_identifier = "kylo-${sha1(timestamp())}"
  multi_az                  = "${var.kylo_db_multi_az}"
  storage_encrypted         = "${var.kylo_db_storage_encrypted}"
  monitoring_interval       = 60
  monitoring_role_arn = "${aws_iam_role.kylo_rds_monitoring.arn}"

  lifecycle {
    ignore_changes = ["final_snapshot_identifier", "storage_encrypted", "snapshot_identifier"]
  }

  tags {
    workload-type = "${terraform.workspace}"
  }
}

resource "random_string" "kylo_db_password" {
  length = 40
  special = false
}

resource "aws_iam_role" "kylo_rds_monitoring" {
  name="${terraform.workspace}_kylo_rds_monitoring_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "monitoring.rds.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

variable "kylo_db_instance_class" {
  description = "The type of the instance for the kylo database"
  default     = "db.m4.large"
}
variable "kylo_db_engine_version" {
  description = "The version of mysql used for kylo"
  default     = "5.7"
}

variable "kylo_db_parameter_group_name" {
  description = "The identifier for the db parameter group for a version of mysql"
  default     = "default.mysql5.7"
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
  default = ""
}

variable "kylo_db_multi_az" {
  description = "is kylo rds db multi az?"
  default = true
}