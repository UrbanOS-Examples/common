resource "aws_kms_key" "cloud_storage_key" {
  description             = "The key used to encrypt the hdfs bucket"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket" "hadoop_cloud_storage" {
  bucket = "${var.cloud_storage_bucket_name}"
  acl    = "private"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = "${aws_kms_key.cloud_storage_key.arn}"
        sse_algorithm     = "aws:kms"
      }
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}