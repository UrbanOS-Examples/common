module "parking_prediction_database" {
  source = "git@github.com:SmartColumbusOS/scos-tf-rds?ref=2.0.0"

  identifier = "${terraform.workspace}-data-science-parking-prediction"
  prefix     = "${terraform.workspace}-data-science-parking-prediction"
  type       = "sqlserver-web"
  version    = "14.00.3223.3.v1"
  port       = "1433"
  username   = "padmin"

  multi_az                            = false
  attached_vpc_id                     = "${module.vpc.vpc_id}"
  attached_subnet_ids                 = "${local.private_subnets}"
  attached_security_groups            = ["${aws_security_group.chatter.id}"]
  attached_security_group_cidr_blocks = ["10.0.0.0/16"]
  instance_class                      = "db.m5.xlarge"
  allocated_storage                   = 1000
}

resource "aws_s3_bucket" "parking_prediction" {
  bucket        = "${terraform.workspace}-parking-prediction"
  acl           = "private"
  force_destroy = "${var.force_destroy_s3_bucket}"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "parking_prediction" {
  bucket = "${aws_s3_bucket.parking_prediction.id}"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "parking_prediction" {
  bucket = "${aws_s3_bucket.parking_prediction.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowSSLRequestsOnly",
      "Action": "s3:*",
      "Effect": "Deny",
      "Resource": "${aws_s3_bucket.parking_prediction.arn}",
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

resource "aws_s3_bucket" "parking_prediction_public" {
  bucket        = "${terraform.workspace}-parking-prediction-public"
  acl           = "public-read"
  force_destroy = "${var.force_destroy_s3_bucket}"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_policy" "parking_prediction_public_ssl_policy" {
  bucket = "${aws_s3_bucket.parking_prediction_public.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowSSLRequestsOnly",
      "Action": "s3:*",
      "Effect": "Deny",
      "Resource": "${aws_s3_bucket.parking_prediction_public.arn}",
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

resource "aws_iam_user" "parking_prediction_api" {
  name = "${terraform.workspace}-parking-prediction-api"
}

resource "aws_iam_user" "parking_prediction_train" {
  name = "${terraform.workspace}-parking-prediction-train"
}

resource "aws_iam_user_policy" "parking_prediction_api_ro" {
  name = "read"
  user = "${aws_iam_user.parking_prediction_api.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1",
      "Action": [
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.parking_prediction.arn}"
    },
    {
      "Sid": "Stmt2",
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": ["${aws_s3_bucket.parking_prediction.arn}/*"]
    }
  ]
}
EOF
}

resource "aws_iam_user_policy" "parking_prediction_train" {
  name = "read"
  user = "${aws_iam_user.parking_prediction_train.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1",
      "Action": [
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": ["${aws_s3_bucket.parking_prediction.arn}", "${aws_s3_bucket.parking_prediction_public.arn}"]
    },
    {
      "Sid": "Stmt2",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:PutObjectAcl"
      ],
      "Effect": "Allow",
      "Resource": ["${aws_s3_bucket.parking_prediction.arn}/*", "${aws_s3_bucket.parking_prediction_public.arn}/*"]
    }
  ]
}
EOF
}

output "data_science_db_server" {
  description = "Data Science MSSQL server url"
  value       = "${module.parking_prediction_database.address}"
}

output "data_science_db_secret_id" {
  description = "Data Science MSSQL server secret"
  value = "${module.parking_prediction_database.password_secret_id}"
}

output "data_science_db_username" {
  description = "Data Science MSSQL username"
  value = "${module.parking_prediction_database.username}"
}
