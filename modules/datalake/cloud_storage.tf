resource "aws_kms_key" "cloud_storage_key" {
  description             = "The key used to encrypt the hdfs bucket"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket" "hadoop_cloud_storage" {
  bucket = "${var.cloud_storage_bucket_prefix}-${terraform.workspace}"
  acl    = "private"

  lifecycle {
    prevent_destroy = true
  }
}