provider "aws" {
  region = "${var.region}"

  assume_role {
    role_arn = "${var.role_arn}"
  }
}

provider "aws" {
  alias  = "alm"
  region = "${var.region}"

  assume_role {
    role_arn = "${var.alm_role_arn}"
  }
}

terraform {
  backend "s3" {
    bucket         = "scos-sandbox-terraform-state"
    key            = "joomla"
    region         = "us-east-2"
    dynamodb_table = "terraform_lock"
    encrypt        = true
  }
}

locals {
  db_name = "joomla"
}

resource "aws_db_subnet_group" "joomladb" {
  name       = "joomladb"
  subnet_ids = ["${var.private_subnet_ids}"]

  tags {
    Name = "joomla"
  }
}

resource "aws_db_instance" "joomladb" {
  allocated_storage    = "${var.db_storage_size}"   //GiB min 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.6.37"
  instance_class       = "${var.db_instance_class}"
  name                 = "${local.db_name}"
  identifier           = "${local.db_name}"
  username             = "${var.db_user}"
  password             = "${var.db_password}"
  parameter_group_name = "default.mysql5.6"

  // this is used to put the db into the correct vpc
  // https://www.terraform.io/docs/providers/aws/r/db_instance.html#db_subnet_group_name
  db_subnet_group_name = "${aws_db_subnet_group.joomladb.name}"
}

data "aws_vpc" "this_vpc" {
  id = "${var.vpc_id}"
}

data "aws_vpc" "alm_vpc" {
  provider = "aws.alm"
  id       = "${var.alm_vpc_id}"
}

resource "aws_security_group" "scos_servers" {
  name        = "SCOS Servers"
  description = "Allows inbound traffic, communication between servers in group, and communication from Admin VPC"
  vpc_id      = "${var.vpc_id}"

  ingress {
    description = "From admin VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${data.aws_vpc.this_vpc.cidr_block}", "${data.aws_vpc.alm_vpc.cidr_block}"]
  }

  ingress {
    description = "Others in this security group"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_key_pair" "joomla" {
  key_name   = "joomla-key"
  public_key = "${var.joomla_public_key}"
}

resource "aws_iam_role" "joomla_role" {
  name = "joomla"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "ecr_registry_pull" {
  name   = "ecr_registry_pull"
  policy = "${file("files/instance_policy.json")}"
  role   = "${aws_iam_role.joomla_role.name}"
}

resource "aws_iam_instance_profile" "joomla_profile" {
  name = "joomla"
  role = "${aws_iam_role.joomla_role.name}"
}

resource "aws_instance" "joomla" {
  ami                    = "ami-922914f7"
  instance_type          = "${var.cluster_instance_type}"
  vpc_security_group_ids = ["${aws_security_group.scos_servers.id}"]

  subnet_id = "${var.private_subnet_ids[0]}"
  key_name  = "${aws_key_pair.joomla.key_name}"

  user_data            = "${file("files/joomla_startup.sh")}"
  iam_instance_profile = "${aws_iam_instance_profile.joomla_profile.name}"

  tags {
    Name = "Joomla"
  }
}
