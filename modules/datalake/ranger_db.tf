resource "aws_kms_key" "ranger_db_key" {
  description             = "ranger db encryption key for ${terraform.workspace}"
}

resource "aws_kms_alias" "ranger_db_key_alias" {
  name_prefix           = "alias/ranger"
  target_key_id         = "${aws_kms_key.ranger_db_key.key_id}"
}

resource "random_string" "ranger_db_password" {
  length = 40
  special = false
}

resource "aws_db_subnet_group" "ranger_db_subnet_group" {
  name        = "ranger db ${terraform.workspace} subnet group"
  description = "DB Subnet Group"
  subnet_ids  = ["${var.db_subnets}"]

  tags {
    Name = "Subnet Group for ranger in Environment ${terraform.workspace} VPC"
  }
}

resource "aws_db_instance" "ranger_db" {
  identifier              = "${terraform.workspace}-ranger"
  name                    = "${local.ranger_db_name}"
  instance_class          = "db.t2.small"
  vpc_security_group_ids  = ["${aws_security_group.ranger_security_group.id}", "${aws_security_group.db_allow_hadoop.id}"]
  db_subnet_group_name    = "${aws_db_subnet_group.ranger_db_subnet_group.name}"
  engine                  = "postgres"
  engine_version          = "10.4"
  allocated_storage       = 100 # The allocated storage in gibibytes.
  storage_type            = "gp2"
  username                = "${local.ranger_db_name}"
  password                = "${random_string.ranger_db_password.result}"
  multi_az                = "${var.ranger_db_multi_az}"
  backup_window           = "04:54-05:24"
  backup_retention_period = 7
  storage_encrypted       = true
  kms_key_id              = "${aws_kms_key.ranger_db_key.arn}"
  apply_immediately       = "${var.ranger_db_apply_immediately}"
  skip_final_snapshot     = "${var.skip_final_db_snapshot}"

  lifecycle = {
    prevent_destroy = true
  }
}
