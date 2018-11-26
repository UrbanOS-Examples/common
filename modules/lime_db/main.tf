resource "aws_kms_key" "lime_db_key" {
  description = "lime db encryption key for ${terraform.workspace}"
}

resource "aws_kms_alias" "lime_db_key_alias" {
  name_prefix   = "alias/lime"
  target_key_id = "${aws_kms_key.lime_db_key.key_id}"
}

resource "random_string" "lime_db_password" {
  length  = 40
  special = false
}

resource "aws_secretsmanager_secret" "lime_db_password" {
  name = "${terraform.workspace}-lime-db-password"
}

resource "aws_secretsmanager_secret_version" "lime_db_password" {
  secret_id     = "${aws_secretsmanager_secret.lime_db_password.id}"
  secret_string = "${random_string.lime_db_password.result}"
}

resource "aws_db_subnet_group" "lime_db_subnet_group" {
  name        = "lime db ${terraform.workspace} subnet group"
  description = "Subnet group for the Lime db"
  subnet_ids  = ["${var.subnets}"]

  tags {
    Name = "Lime db for ${terraform.workspace} env"
  }
}

resource "aws_security_group" "lime_security_group" {
  name_prefix = "allow_postgres_"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    description = "Allow traffic from self"
  }

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = ["${aws_security_group.chatter.id}"]
    description     = "Allow ingress from EKS-deployed app to its database"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "lime_db" {
  identifier              = "${terraform.workspace}-lime"
  name                    = "${var.lime_db_name}"
  instance_class          = "db.t2.small"
  vpc_security_group_ids  = ["${aws_security_group.lime_security_group.id}"]
  db_subnet_group_name    = "${aws_db_subnet_group.lime_db_subnet_group.name}"
  engine                  = "postgres"
  engine_version          = "10.4"
  allocated_storage       = 100 # in gigabytes
  storage_type            = "gp2"
  username                = "${var.lime_db_name}"
  password                = "${random_string.lime_db_password.result}"
  multi_az                = "${var.lime_db_multi_az}"
  backup_window           = "04:54-05:24"
  backup_retention_period = 7
  storage_encrypted       = true
  kms_key_id              = "${aws_kms_key.lime_db_key.arn}"
  apply_immediately       = "${var.lime_db_apply_immediately}"
  skip_final_snapshot     = "${var.final_db_snapshot}"

  lifecycle = {
    prevent_destroy = true
  }
}
