resource "aws_s3_bucket" "os_public_data" {
  bucket        = "${terraform.workspace}-os-public-data"
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

resource "aws_s3_bucket_policy" "os_public_data_ssl_policy" {
  bucket = "${aws_s3_bucket.os_public_data.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowSSLRequestsOnly",
      "Action": "s3:*",
      "Effect": "Deny",
      "Resource": "${aws_s3_bucket.os_public_data.arn}",
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

resource "aws_s3_bucket" "os_hosted_datasets" {
  bucket        = "${terraform.workspace}-hosted-dataset-files"
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

resource "aws_s3_bucket_public_access_block" "os_hosted_datasets_s3_access" {
  bucket = "${aws_s3_bucket.os_hosted_datasets.id}"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "os_hosted_datasets_ssl_policy" {
  bucket = "${aws_s3_bucket.os_hosted_datasets.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowSSLRequestsOnly",
      "Action": "s3:*",
      "Effect": "Deny",
      "Resource": "${aws_s3_bucket.os_hosted_datasets.arn}",
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

resource "aws_s3_bucket" "ckan" {
  #keep to preserve copy of CKAN data
  bucket        = "${terraform.workspace}-os-ckan-data"
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

resource "aws_s3_bucket_public_access_block" "ckan_s3_access" {
  bucket = "${aws_s3_bucket.ckan.id}"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "ckan_ssl_policy" {
  bucket = "${aws_s3_bucket.ckan.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowSSLRequestsOnly",
      "Action": "s3:*",
      "Effect": "Deny",
      "Resource": "${aws_s3_bucket.ckan.arn}",
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