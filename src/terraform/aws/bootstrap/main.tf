provider "aws" {
  region = "${var.region}"
}

resource "aws_s3_bucket" "terraform-state" {
  bucket = "${var.bucket_name}"
  acl    = "private"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags {
    type        = "devops"
    Environment = "Application Lifecycle Management"
  }
}

resource "aws_dynamodb_table" "dynamodb-terraform-state-lock" {
  name           = "${var.lock_table_name}"
  hash_key       = "LockID"
  read_capacity  = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }

  lifecycle {
    prevent_destroy = true
  }

  tags {
    Name = "DynamoDB Terraform StateLockTable"
  }
}
