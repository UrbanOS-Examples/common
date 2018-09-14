
data "archive_file" "alert_handler_zip" {
    type        = "zip"
    source_dir  = "${path.module}/files/lambda/alert_handler"
    output_path = "lambda_alert_handler.zip"
}

resource "aws_iam_policy" "alert_handler_iam_policy" {
  name = "${terraform.workspace}_lambda_alert_handler_policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [ {
    "Effect": "Allow",
    "Action": "logs:CreateLogGroup",
    "Resource": "arn:aws:logs:*:*:*"
  }, {
    "Effect": "Allow",
    "Action": [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ],
    "Resource": "arn:aws:logs:*:*:*:*"
  }, {
    "Effect": "Allow",
    "Action": "sns:Publish",
    "Resource": "arn:aws:sns:*:*:*"
  } ]
}
EOF
}

resource "aws_iam_role" "alert_handler_iam_role" {
  name = "${terraform.workspace}_lambda_alert_handler_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "alert_handler_iam_rolepolicy_attachment" {
  role = "${aws_iam_role.alert_handler_iam_role.name}"
  policy_arn = "${aws_iam_policy.alert_handler_iam_policy.arn}"
}

resource "aws_lambda_function" "alert_handler_lambda" {
  filename = "lambda_alert_handler.zip"
  source_code_hash = "${data.archive_file.alert_handler_zip.output_base64sha256}"
  function_name = "${terraform.workspace}_alert_handler"
  role = "${aws_iam_role.alert_handler_iam_role.arn}"
  description = "An Amazon SNS trigger that sends CloudWatch alarm notifications to Slack."
  handler = "index.handler"
  runtime = "nodejs8.10"
  timeout       = 30
  environment {
    variables {
      SLACK_PATH = "${var.slack_path}"
      SLACK_CHANNEL_NAME = "${var.slack_channel_name}"
    }
  }
}

variable "slack_path" {
  description = "Path to the Slack channel"
  default = "/services/T7LRETX4G/BA0EW8W6R/vRbX198LKBkhAEK64OnHCUXH"
}

variable "slack_channel_name" {
  description = "Name of the Slack channel"
}