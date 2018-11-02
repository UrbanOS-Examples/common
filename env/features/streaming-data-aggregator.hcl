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
              "${module.eks-cluster.worker_iam_role_arn}"
            ]
           },
         "Action": [
            "s3:ListBucket"
         ],
         "Resource": "${aws_s3_bucket.streaming_data_aggregator.arn}"
      },
      {
         "Effect": "Allow",
         "Principal": {
           "AWS":
            [
              "${module.eks-cluster.worker_iam_role_arn}"
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
