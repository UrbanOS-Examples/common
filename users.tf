resource "aws_iam_user" "discovery_api_user" {
  name = "${terraform.workspace}-discovery-api"
}

resource "aws_iam_user_policy" "discovery_api_user_ro" {
  name = "read"
  user = aws_iam_user.discovery_api_user.name

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

resource "aws_iam_user" "reaper_user" {
  name = "${terraform.workspace}-reaper"
}

resource "aws_iam_user_policy" "reaper_user_ro" {
  name = "write"
  user = aws_iam_user.reaper_user.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt2",
      "Action": [
        "s3:Get*",
        "s3:List*",
        "s3:putObject"
      ],
      "Effect": "Allow",
      "Resource": ["${aws_s3_bucket.os_hosted_datasets.arn}/*"]
    },
    {
      "Sid": "Stmt3",
      "Action": [
        "s3:Get*",
        "s3:List*"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::*/*",
        "arn:aws:s3:::*"
        ]
    }
  ]
}
EOF

}

resource "aws_iam_user" "andi_user" {
  name = "${terraform.workspace}-andi"
}

resource "aws_iam_user_policy" "andi_user_ro" {
  name = "write"
  user = aws_iam_user.andi_user.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1",
      "Action": [
        "s3:List*",
        "s3:putObject",
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": ["${aws_s3_bucket.andi_public_sample_datasets.arn}/*"]
    }
  ]
}
EOF

}

resource "aws_iam_user" "odo_user" {
  name = "${terraform.workspace}-odo"
}

resource "aws_iam_user_policy" "odo_user_rw" {
  name = "read-write"
  user = aws_iam_user.odo_user.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1",
      "Action": [
        "s3:putObject",
        "s3:getObject"
      ],
      "Effect": "Allow",
      "Resource": ["${aws_s3_bucket.os_hosted_datasets.arn}/*"]
    }
  ]
}
EOF

}

output "andi_aws_user_name" {
  value = aws_iam_user.andi_user.name
}

output "odo_aws_user_name" {
  value = aws_iam_user.odo_user.name
}

output "reaper_aws_user_name" {
  value = aws_iam_user.reaper_user.name
}

output "discovery_api_aws_user_name" {
  value = aws_iam_user.discovery_api_user.name
}
