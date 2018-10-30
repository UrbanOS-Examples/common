resource "aws_iam_role" "cloudstorage_bucket_access" {
  name = "${terraform.workspace}_cloudstorage_bucket_access"
  path = "/"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow"
      }
    ]
}
EOF
}

resource "aws_iam_instance_profile" "cloudstorage_bucket_access" {
  name = "${terraform.workspace}_cloudstorage_bucket_access"
  role = "${aws_iam_role.cloudstorage_bucket_access.name}"
}

resource "aws_iam_role_policy" "cloudstorage_bucket_access" {
  name = "cloudstorage_bucket_access"
  role = "${aws_iam_role.cloudstorage_bucket_access.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": [
                "${aws_s3_bucket.hadoop_cloud_storage.arn}",
                "${aws_s3_bucket.hadoop_cloud_storage.arn}/*"
            ]
        }
    ]
}
EOF
}
