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
              "arn:aws:iam::068920858268:role/admin_role",
              "arn:aws:iam::199837183662:role/jenkins_role"
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

output "smart_os_initial_state_bucket_name" {
  value = "${aws_s3_bucket.smart_os_initial_state_backups.id}"
}

output "smart_os_initial_state_bucket_region" {
  value = "${aws_s3_bucket.smart_os_initial_state_backups.region}"
}

output "smart_os_initial_state_bucket_arn" {
  value= "${aws_s3_bucket.smart_os_initial_state_backups.arn}"
}