module "joomla_db" {
  source                   = "git@github.com:SmartColumbusOS/scos-tf-rds?ref=1.4.0"
  identifier               = "${terraform.workspace}-joomla"
  prefix                   = "${terraform.workspace}-joomla"
  database_name            = "joomla"
  type                     = "mysql"
  attached_vpc_id          = "${module.vpc.vpc_id}"
  attached_subnet_ids      = "${local.private_subnets}"
  attached_security_groups = ["${aws_security_group.chatter.id}"]
  instance_class           = "${var.joomla_db_instance_class}"
}

resource "aws_s3_bucket" "joomla-backups" {
  bucket        = "${terraform.workspace}-os-joomla-backups"
  acl           = "private"
  force_destroy = "${var.force_destroy_s3_bucket}"

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

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_policy" "joomla-backups_ssl_policy" {
  bucket = "${aws_s3_bucket.joomla-backups.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowSSLRequestsOnly",
      "Action": "s3:*",
      "Effect": "Deny",
      "Resource": "${aws_s3_bucket.joomla-backups.arn}",
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      },
      "Principal": "*"
    }
  ]
}
POLICY
}

resource "aws_s3_bucket_public_access_block" "jooma_s3_access" {
  bucket = "${aws_s3_bucket.joomla-backups.id}"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

variable "joomla_db_instance_class" {
  description = "AWS instance class for joomla rds instance"
  default = "db.t2.large"
}
