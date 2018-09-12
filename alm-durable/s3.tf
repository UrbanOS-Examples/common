resource "aws_s3_bucket" "smart_os_initial_state_backups" {
  bucket = "smart-os-initial-state-backups-${var.environment}"
  acl    = "private"

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_policy" "smart_os_initial_state_backups" {
  bucket = "${aws_s3_bucket.smart_os_initial_state_backups.id}"
  policy =<<POLICY
{
   "Version": "2012-10-17",
   "Statement": [
      {
         "Effect": "Allow",
         "Principal": {
           "AWS":
            [
              "arn:aws:iam::199837183662:role/jenkins_role",
              "arn:aws:iam::068920858268:root",
              "arn:aws:iam::073132350570:root",
              "arn:aws:iam::647770347641:root",
              "arn:aws:iam::374013108165:root"
            ]
           },
         "Action": [
            "s3:GetObject"
         ],
         "Resource": "${aws_s3_bucket.smart_os_initial_state_backups.arn}/*"
      }
   ]
}
POLICY
}

resource "aws_s3_bucket" "scospy-repository" {
  bucket = "${var.scospy_repo_name}"
  acl    = "public-read"
  tags {
    Name        = "scospy-repository"
    Environment = "${terraform.workspace}"
  }
}

resource "aws_s3_bucket_policy" "scospy-repository-policy" {
  bucket = "${aws_s3_bucket.scospy-repository.id}"
  policy =<<POLICY
{
  "Version":"2012-10-17",
  "Statement":[{
      "Sid":"AddPerm",
      "Effect":"Allow",
      "Principal": "*",
      "Action":["s3:GetObject"],
      "Resource":["${aws_s3_bucket.scospy-repository.arn}/*"]
    }
  ]
}
POLICY
}

resource "aws_s3_bucket" "build_artifacts_repository" {
  bucket = "${var.build_artifacts_repo_name}"
  acl    = "public-read"
  tags {
    Name        = "build-artifacts-repository"
    Environment = "${terraform.workspace}"
  }
}

resource "aws_s3_bucket_policy" "build_artifacts_repository_policy" {
  bucket = "${aws_s3_bucket.build_artifacts_repository.id}"
  policy =<<POLICY
{
  "Version":"2012-10-17",
  "Statement":[{
      "Sid":"AddPerm",
      "Effect":"Allow",
      "Principal": "*",
      "Action":["s3:GetObject"],
      "Resource":["${aws_s3_bucket.build_artifacts_repository.arn}/*"]
    }
  ]
}
POLICY
}
variable "build_artifacts_repo_name" {
  default = "os-build-artifacts-repository"
  description = "Bucket name to archive build artifacts"
}

variable "scospy_repo_name" {
  default = "scospy-repository"
  description = "Bucket name to archive scospy build artifacts"
}

output "smart_os_initial_state_bucket_name" {
  value = "${aws_s3_bucket.smart_os_initial_state_backups.id}"
}

output "smart_os_initial_state_bucket_region" {
  value = "${aws_s3_bucket.smart_os_initial_state_backups.region}"
}

output "smart_os_initial_state_bucket_arn" {
  value= "${aws_s3_bucket.smart_os_initial_state_backups.arn}"
}
