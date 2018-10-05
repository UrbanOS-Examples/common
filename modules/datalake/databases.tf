resource "aws_kms_key" "cloudbreak_db_key" {
  description             = "cloudbreak db encryption key for ${terraform.workspace}"
}

resource "aws_kms_alias" "cloudbreak_db_key_alias" {
  name_prefix           = "alias/cloudbreak"
  target_key_id         = "${aws_kms_key.cloudbreak_db_key.key_id}"
}

resource "random_string" "cloudbreak_db_password" {
  length = 40
  special = false
}

resource "aws_kms_key" "hive_db_key" {
  description             = "hive db encryption key for ${terraform.workspace}"
}

resource "aws_kms_alias" "hive_db_key_alias" {
  name_prefix           = "alias/hive"
  target_key_id         = "${aws_kms_key.hive_db_key.key_id}"
}

resource "random_string" "hive_db_password" {
  length = 40
  special = false
}

resource "aws_db_subnet_group" "cloudbreak_db_subnet_group" {
  name        = "cloudbreak db ${terraform.workspace} subnet group"
  description = "DB Subnet Group"
  subnet_ids  = ["${var.subnets}"]

  tags {
    Name = "Subnet Group for Cloudbreak in Environment ${terraform.workspace} VPC"
  }
}

resource "aws_db_subnet_group" "hive_db_subnet_group" {
  name        = "hive db ${terraform.workspace} subnet group"
  description = "DB Subnet Group"
  subnet_ids  = ["${var.subnets}"]

  tags {
    Name = "Subnet Group for Hive in Environment ${terraform.workspace} VPC"
  }
}

resource "aws_db_instance" "cloudbreak_db" {
  identifier              = "${terraform.workspace}-cloudbreak"
  instance_class          = "db.t2.small"
  vpc_security_group_ids  = ["${aws_security_group.cloudbreak_security_group.id}"]
  db_subnet_group_name    = "${aws_db_subnet_group.cloudbreak_db_subnet_group.name}"
  engine                  = "postgres"
  engine_version          = "10.4"
  allocated_storage       = 100 # The allocated storage in gibibytes.
  storage_type            = "gp2"
  username                = "cloudbreak"
  password                = "${random_string.cloudbreak_db_password.result}"
  multi_az                = "${var.cloudbreak_db_multi_az}"
  backup_window           = "04:54-05:24"
  backup_retention_period = 7
  storage_encrypted       = true
  kms_key_id              = "${aws_kms_key.cloudbreak_db_key.arn}"
  apply_immediately       = "${var.cloudbreak_db_apply_immediately}"

  lifecycle = {
    prevent_destroy = true
  }
}

resource "aws_db_instance" "hive_db" {
  identifier              = "${terraform.workspace}-hive"
  name                    = "hive"
  instance_class          = "db.t2.small"
  vpc_security_group_ids  = ["${aws_security_group.hive_security_group.id}", "${aws_security_group.postgres_allow_hdpdbs.id}"]
  db_subnet_group_name    = "${aws_db_subnet_group.hive_db_subnet_group.name}"
  engine                  = "postgres"
  engine_version          = "10.4"
  allocated_storage       = 100 # The allocated storage in gibibytes.
  storage_type            = "gp2"
  username                = "hive"
  password                = "${random_string.hive_db_password.result}"
  multi_az                = "${var.hive_db_multi_az}"
  backup_window           = "04:54-05:24"
  backup_retention_period = 7
  storage_encrypted       = true
  kms_key_id              = "${aws_kms_key.hive_db_key.arn}"
  apply_immediately       = "${var.hive_db_apply_immediately}"

  lifecycle = {
    prevent_destroy = true
  }
}
