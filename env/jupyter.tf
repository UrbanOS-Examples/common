resource "aws_s3_bucket" "jupyter_backup" {
  bucket = "${terraform.workspace}-jupyter-backup"

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
    Description = "Live backups for Jupyter Notebooks"
    Environment = "${terraform.workspace}"
  }
}
