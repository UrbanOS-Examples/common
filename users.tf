resource "aws_iam_user" "discovery_api_user" {
  name = "${terraform.workspace}-discovery-api"
}

resource "aws_iam_user_policy" "discovery_api_user_ro" {
  name = "read"
  user = "${aws_iam_user.discovery_api_user.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1",
      "Action": [
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.os_hosted_datasets.arn}"
    },
    {
      "Sid": "Stmt2",
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": ["${aws_s3_bucket.os_hosted_datasets.arn}/*"]
    }
  ]
}
EOF
}
