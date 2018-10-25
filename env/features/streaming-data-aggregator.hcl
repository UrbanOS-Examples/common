resource "aws_s3_bucket" "streaming_data_aggregator" {
  bucket = "streaming-data-aggregator-${terraform.workspace}"
  acl    = "private"

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_policy" "streaming_data_aggregator" {
  bucket = "${aws_s3_bucket.streaming_data_aggregator.id}"
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
            "s3:GetObject",
            "s3:PutObject"
         ],
         "Resource": "${aws_s3_bucket.streaming_data_aggregator.arn}/*"
      }
   ]
}
POLICY
}
