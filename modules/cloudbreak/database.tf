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

resource "aws_db_subnet_group" "cloudbreak_db_subnet_group" {
  name        = "cloudbreak db ${terraform.workspace} subnet group"
  description = "DB Subnet Group"
  subnet_ids  = ["${var.subnets}"]

  tags {
    Name = "Subnet Group for Cloudbreak in Environment ${terraform.workspace} VPC"
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
