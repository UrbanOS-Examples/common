resource "aws_s3_bucket" "os_public_data" {
  bucket        = "${terraform.workspace}-os-public-data"
  acl           = "public-read"
  force_destroy = true
}
