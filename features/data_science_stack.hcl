module "parking_prediction_database" {
  source = "git@github.com:SmartColumbusOS/scos-tf-rds?ref=1.2.0"

  identifier = "${terraform.workspace}-data-science-parking-prediction"
  prefix     = "${terraform.workspace}-data-science-parking-prediction"
  type       = "sqlserver-web"
  version    = "14.00.3223.3.v1"
  port       = "1433"
  username   = "padmin"

  multi_az                 = false
  attached_vpc_id          = "${module.vpc.vpc_id}"
  attached_subnet_ids      = "${local.private_subnets}"
  attached_security_groups = ["${aws_security_group.chatter.id}","${aws_security_group.database_vpn_access.id}"]
  instance_class           = "db.m5.xlarge"
  allocated_storage        = 1000
}

resource "aws_security_group" "database_vpn_access" {
  name        = "database_vpn_access"
  description = "Security to allow direct connection to the data science database via the vpn"
  vpc_id      = "${module.vpc.vpc_id}"

  tags = {
    Name = "Ingress for the data science RDS."
  }

  ingress {
    description = "Allow VPN access."
    from_port   = 1433
    to_port     = 1433
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
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
  bucket = "${aws_s3_bucket.ckan.id}"

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

resource "aws_iam_user" "parking_prediction_api" {
  name = "${terraform.workspace}-parking-prediction-api"
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