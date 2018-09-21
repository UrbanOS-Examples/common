
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
  subnet_ids  = ["${module.vpc.private_subnets}"]

  tags {
    Name = "Subnet Group for Cloudbreak in Environment ${terraform.workspace} VPC"
  }
}

resource "aws_security_group" "cloudbreak_security_group" {
  name   = "Cloudbreak Security Group"
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

resource "aws_db_instance" "cloudbreak_db" {
  identifier              = "${terraform.workspace}-cloudbreak"
  instance_class          = "db.t2.small"
  vpc_security_group_ids  = ["${aws_security_group.cloudbreak_security_group.id}"]
  db_subnet_group_name    = "${aws_db_subnet_group.cloudbreak_db_subnet_group.name}"
  engine                  = "postgres"
  engine_version          = "10.4"
  allocated_storage       = 100
  storage_type            = "gp2"
  username                = "cloudbreak"
  password                = "${random_string.cloudbreak_db_password.result}"
  multi_az                = true
  backup_window           = "04:54-05:24"
  backup_retention_period = 7
  storage_encrypted       = true
  kms_key_id              = "${aws_kms_key.cloudbreak_db_key.arn}"

  lifecycle = {
    prevent_destroy = true
  }
}
