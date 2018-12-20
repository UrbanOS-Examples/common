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

resource "aws_secretsmanager_secret" "hive_db_password" {
  name = "${terraform.workspace}-hive-db-password"
  recovery_window_in_days = "${var.recovery_window_in_days}"
}

resource "aws_secretsmanager_secret_version" "hive_db_password" {
  secret_id     = "${aws_secretsmanager_secret.hive_db_password.id}"
  secret_string = "${random_string.hive_db_password.result}"
}

resource "aws_secretsmanager_secret" "hive_thrift_password" {
  name = "${terraform.workspace}-hive-thrift-password"
  recovery_window_in_days = "${var.recovery_window_in_days}"
}

resource "aws_secretsmanager_secret_version" "hive_thrift_password" {
  secret_id     = "${aws_secretsmanager_secret.hive_thrift_password.id}"
  secret_string = "isnotsetinambariblueprint"
}


resource "aws_db_subnet_group" "hive_db_subnet_group" {
  name        = "hive db ${terraform.workspace} subnet group"
  description = "DB Subnet Group"
  subnet_ids  = ["${var.db_subnets}"]

  tags {
    Name = "Subnet Group for Hive in Environment ${terraform.workspace} VPC"
  }
}

resource "aws_db_instance" "hive_db" {
  identifier              = "${terraform.workspace}-hive"
  name                    = "${local.hive_db_name}"
  instance_class          = "db.t2.small"
  vpc_security_group_ids  = ["${aws_security_group.hive_security_group.id}", "${aws_security_group.db_allow_hadoop.id}"]
  db_subnet_group_name    = "${aws_db_subnet_group.hive_db_subnet_group.name}"
  engine                  = "postgres"
  engine_version          = "10.4"
  allocated_storage       = 100 # The allocated storage in gibibytes.
  storage_type            = "gp2"
  username                = "${local.hive_db_name}"
  password                = "${random_string.hive_db_password.result}"
  multi_az                = "${var.hive_db_multi_az}"
  backup_window           = "04:54-05:24"
  backup_retention_period = 7
  storage_encrypted       = true
  kms_key_id              = "${aws_kms_key.hive_db_key.arn}"
  apply_immediately       = "${var.hive_db_apply_immediately}"
  skip_final_snapshot     = "${var.skip_final_db_snapshot}"

  lifecycle = {
    prevent_destroy = true
  }
}

resource "null_resource" "cloudbreak_hive_db" {
  triggers {
    setup_updated    = "${sha1(file(local.ensure_db_path))}"
    id_updated       = "${local.hive_db_name}"
    cloudbreak_ready = "${var.cloudbreak_ready}"
  }

  connection {
    type = "ssh"
    host = "${var.cloudbreak_ip}"
    user = "ec2-user"
  }

  provisioner "file" {
    source      = "${local.ensure_db_path}"
    destination = "/tmp/ensure_databases.sh"
  }

  provisioner "remote-exec" {
    inline = [
      <<EOF
bash /tmp/ensure_databases.sh \
  jdbc:postgresql://${aws_db_instance.hive_db.endpoint}/${aws_db_instance.hive_db.name} \
  ${local.hive_db_name} \
  ${aws_db_instance.hive_db.password} \
  HIVE
EOF
      ,
      <<EOF
bash /tmp/ensure_databases.sh \
  jdbc:postgresql://${aws_db_instance.ranger_db.endpoint}/${aws_db_instance.ranger_db.name} \
  ${local.ranger_db_name} \
  ${aws_db_instance.ranger_db.password} \
  RANGER
EOF
      ,
    ]
  }

  lifecycle {
    create_before_destroy = true
  }
}
