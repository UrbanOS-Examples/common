resource "aws_iam_service_linked_role" "config" {
  aws_service_name = "config.amazonaws.com"
}

resource "aws_config_configuration_recorder" "config_default" {
  name     = "default"
  role_arn = "${aws_iam_service_linked_role.config.arn}"

  recording_group = {
    all_supported = true
    include_global_resource_types = true
  }
}

resource "aws_config_delivery_channel" "config_default" {
  name           = "default"
  s3_bucket_name = "${aws_s3_bucket.config.bucket}"
  depends_on     = ["aws_config_configuration_recorder.config_default"]
}


resource "aws_s3_bucket" "config" {
  bucket = "config-bucket-${data.aws_caller_identity.current.account_id}"
  acl    = "private"

  force_destroy = "${var.force_destroy_s3_bucket}"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "config" {
  bucket = "${aws_s3_bucket.config.id}"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "config" {
  bucket = "${aws_s3_bucket.config.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AWSConfigBucketPermissionsCheck",
      "Effect": "Allow",
      "Principal": {
        "Service": "config.amazonaws.com"
      },
      "Action": "s3:GetBucketAcl",
      "Resource": "${aws_s3_bucket.config.arn}"
    },
    {
      "Sid": "AWSConfigBucketDelivery",
      "Effect": "Allow",
      "Principal": {
        "Service": "config.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "${aws_s3_bucket.config.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/Config/*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        }
      }
    },
    {
      "Sid": "AllowSSLRequestsOnly",
      "Action": "s3:*",
      "Effect": "Deny",
      "Resource": "${aws_s3_bucket.config.arn}",
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
