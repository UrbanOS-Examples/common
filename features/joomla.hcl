resource "aws_db_instance" "joomla_db" {
  identifier                 = "${var.joomla_db_identifier}-${terraform.workspace}"
  instance_class             = "${var.joomla_db_instance_class}"
  vpc_security_group_ids     = ["${aws_security_group.os_servers.id}", "${aws_security_group.joomla_db.id}"]
  db_subnet_group_name       = "${aws_db_subnet_group.default.name}"
  skip_final_snapshot        = true
  engine                     = "mysql"
  engine_version             = "5.6.37"
  parameter_group_name       = "default.mysql5.6"
  allocated_storage          = 100
  storage_type               = "gp2"
  username                   = "joomla"
  password                   = "${random_string.joomla_db_password.result}"
  multi_az                   = "${var.joomla_db_multi_az}"
  auto_minor_version_upgrade = false

  tags {
    workload-type = "other"
  }
}

module "joomla_db" {
  source                   = "git@github.com:SmartColumbusOS/scos-tf-rds?ref=1.0.3"
  identifier               = "${terraform.workspace}-joomla"
  prefix                   = "${terraform.workspace}-joomla"
  database_name            = "joomla"
  type                     = "mysql"
  attached_vpc_id          = "${module.vpc.vpc_id}"
  attached_subnet_ids      = "${local.private_subnets}"
  attached_security_groups = ["${aws_security_group.chatter.id}"]
  instance_class           = "db.t2.large"
}

resource "aws_security_group" "joomla_db" {
  name   = "joomla_database"
  vpc_id = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    description = "Allow traffic from self"
  }

  ingress {
    from_port       = 3306
    to_port         = 3306
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

resource "aws_s3_bucket" "joomla-backups" {
  bucket        = "${terraform.workspace}-os-joomla-backups"
  acl           = "private"
  force_destroy = true

  lifecycle_rule {
    enabled = true

    transition {
      days          = 30
      storage_class = "GLACIER"
    }

    expiration {
      days = 183
    }
  }
}

resource "random_string" "joomla_db_password" {
  length  = 40
  special = false
}

variable "joomla_db_identifier" {
  description = "AWS RDS identifier for joomla db instance"
  default     = "joomla"
}

variable "joomla_db_instance_class" {
  description = "The type of the instance for the joomla database"
  default     = "db.t2.large"
}

variable "joomla_db_multi_az" {
  description = "is joomla rds db multi az?"
  default     = false
}

output "joomla_db_instance_id" {
  value = "${aws_db_instance.joomla_db.id}"
}
