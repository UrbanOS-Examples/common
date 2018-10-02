
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

resource "aws_db_subnet_group" "hive_db_subnet_group" {
  name        = "hive db ${terraform.workspace} subnet group"
  description = "DB Subnet Group"
  subnet_ids  = ["${module.vpc.private_subnets}"]

  tags {
    Name = "Subnet Group for Hive in Environment ${terraform.workspace} VPC"
  }
}

resource "aws_security_group" "hive_security_group" {
  name   = "Hive Security Group"
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

resource "aws_db_instance" "hive_db" {
  identifier              = "${terraform.workspace}-hive"
  name                    = "hive"
  instance_class          = "db.t2.small"
  vpc_security_group_ids  = ["${aws_security_group.hive_security_group.id}", "${aws_security_group.postgres_allow_cloudbreak.id}"]
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

variable "hive_db_multi_az" {
  description = "Should the Hive DB be multi-az?"
  default     = true
}

variable "hive_db_apply_immediately" {
  description = "Should changes to the Hive DB be applied immediately?"
  default = false
}
