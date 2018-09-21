
resource "aws_kms_key" "ambari_db_key" {
  description             = "ambari db encryption key for ${terraform.workspace}"
}

resource "aws_kms_alias" "ambari_db_key_alias" {
  name_prefix           = "alias/ambari"
  target_key_id         = "${aws_kms_key.ambari_db_key.key_id}"
}

resource "random_string" "ambari_db_password" {
  length = 40
  special = false
}

resource "aws_db_subnet_group" "ambari_db_subnet_group" {
  name        = "ambari db ${terraform.workspace} subnet group"
  description = "DB Subnet Group"
  subnet_ids  = ["${module.vpc.private_subnets}"]

  tags {
    Name = "Subnet Group for Ambari in Environment ${terraform.workspace} VPC"
  }
}

resource "aws_security_group" "ambari_security_group" {
  name   = "Ambari Security Group"
  vpc_id = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    description = "Allow traffic from self"
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${data.terraform_remote_state.alm_remote_state.vpc_cidr_block}"]
    description = "Allow all traffic from admin VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "ambari_db" {
  identifier              = "${terraform.workspace}-ambari"
  instance_class          = "db.t2.small"
  vpc_security_group_ids  = ["${aws_security_group.ambari_security_group.id}"]
  db_subnet_group_name    = "${aws_db_subnet_group.ambari_db_subnet_group.name}"
  engine                  = "postgres"
  engine_version          = "10.4"
  allocated_storage       = 100 # The allocated storage in gibibytes.
  storage_type            = "gp2"
  username                = "ambari"
  password                = "${random_string.ambari_db_password.result}"
  multi_az                = "${var.ambari_db_multi_az}"
  backup_window           = "04:54-05:24"
  backup_retention_period = 7
  storage_encrypted       = true
  kms_key_id              = "${aws_kms_key.ambari_db_key.arn}"

  lifecycle = {
    prevent_destroy = true
  }
}

variable "ambari_db_multi_az" {
  description = "Should the Ambari DB be multi-az?"
  default     = true
}
