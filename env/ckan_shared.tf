data "template_file" "ckan_upgrade" {
  template = "${file("${path.module}/files/ckan/ckan-2.8.sh.tpl")}"

  vars {
    THEME_VERSION = "${var.ckan_theme_version}"
  }
}

resource "aws_s3_bucket" "ckan" {
  bucket        = "${terraform.workspace}-os-ckan-data"
  acl           = "private"
  force_destroy = true
}

resource "aws_iam_user" "s3_serviceaccount" {
  name          = "${terraform.workspace}-s3-serviceaccount"
  force_destroy = true
}

resource "aws_iam_user_policy_attachment" "s3_serviceaccount_policy_attachment" {
  user       = "${aws_iam_user.s3_serviceaccount.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_access_key" "s3_serviceaccount_credentials" {
  user       = "${aws_iam_user.s3_serviceaccount.name}"
}

resource "aws_iam_instance_profile" "ckan" {
  name = "${terraform.workspace}_ckan"
  role = "${aws_iam_role.ckan_ec2.name}"
}

resource "aws_iam_role" "ckan_ec2" {
  name = "${terraform.workspace}_ckan_ec2"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "ckan_data_s3_policy" {
  name = "ckan_s3_bucket_policy"
  role = "${aws_iam_role.ckan_ec2.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": ["${aws_s3_bucket.ckan.arn}/*", "${aws_s3_bucket.ckan.arn}"]
    }
  ]
}
EOF
}

resource "aws_db_instance" "ckan" {
  identifier                = "${terraform.workspace}-${var.ckan_db_identifier}"
  instance_class            = "${var.ckan_db_instance_class}"
  vpc_security_group_ids    = ["${aws_security_group.os_servers.id}"]
  db_subnet_group_name      = "${aws_db_subnet_group.default.name}"
  skip_final_snapshot       = false
  engine                    = "postgres"
  engine_version            = "${var.ckan_db_engine_version}"
  parameter_group_name      = "${var.ckan_db_parameter_group_name}"
  allocated_storage         = "${var.ckan_db_allocated_storage}"
  storage_type              = "gp2"
  username                  = "sysadmin"
  password                  = "${random_string.ckan_db_password_sysadmin.result}"
  snapshot_identifier       = "${var.ckan_db_snapshot_id}"
  final_snapshot_identifier = "ckan-${sha1(timestamp())}"
  multi_az                  = "${var.ckan_db_multi_az}"
  storage_encrypted         = "${var.ckan_db_storage_encrypted}"
  monitoring_interval       = 60
  monitoring_role_arn = "${aws_iam_role.ckan_rds_monitoring.arn}"

  lifecycle {
    ignore_changes = ["final_snapshot_identifier", "storage_encrypted", "snapshot_identifier"]
  }

  tags {
    workload-type = "${terraform.workspace}"
  }
}

resource "aws_iam_role" "ckan_rds_monitoring" {
  name="${terraform.workspace}_os_rds_monitoring_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "monitoring.rds.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "random_string" "ckan_db_password_sysadmin" {
  length = 40
  special = false
}

resource "random_string" "ckan_db_password_ckan" {
  length = 40
  special = false
}

resource "random_string" "ckan_db_password_datastore" {
  length = 40
  special = false
}

variable "ckan_db_identifier" {
  description = "AWS RDS identifier for ckan_internal db instance"
  default     = "production-ckan"
}

variable "ckan_db_storage_encrypted" {
  description = "Is ckan db encrypted"
  default     = true
}

variable "ckan_db_snapshot_id" {
  description = "The id of the ckan RDS snapshot to restore"
}

variable "ckan_db_multi_az" {
  description = "is ckan rds db multi az?"
  default = false
}

variable "ckan_db_instance_class" {
  description = "The type of the instance for the ckan database"
  default     = "db.m4.large"
}

variable "ckan_db_allocated_storage" {
  description = "The size of the ckan database in GB"
  default     = 1000
}

variable "ckan_db_parameter_group_name" {
  description = "The identifier for the db parameter group for a version of postgres"
  default     = "default.postgres9.6"
}

variable "ckan_db_engine_version" {
  description = "The version of postgresql used for ckan"
  default     = "9.6.6"
}

variable "ckan_theme_version" {
  description = "The version of the custom ckan theme to install"
  default     = "1.0.7"
}
