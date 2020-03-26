resource "aws_s3_bucket" "os_public_data" {
  bucket        = "${terraform.workspace}-os-public-data"
  acl           = "public-read"
  force_destroy = "${var.force_destroy_s3_bucket}"
}

resource "aws_s3_bucket" "os_hosted_datasets" {
  bucket        = "${terraform.workspace}-hosted-dataset-files"
  acl           = "private"
  force_destroy = "${var.force_destroy_s3_bucket}"
}

resource "aws_s3_bucket" "ckan" {
  #keep to preserve copy of CKAN data
  bucket        = "${terraform.workspace}-os-ckan-data"
  acl           = "private"
  force_destroy = "${var.force_destroy_s3_bucket}"
}