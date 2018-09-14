
module "lambda" {
  source = "github.com/claranet/terraform-aws-lambda"

  function_name = "slack-notifications"
  description   = "An Amazon SNS trigger that sends CloudWatch alarm notifications to Slack."
  handler       = "index.handler"
  runtime       = "nodejs4.3"
  timeout       = 3

  // Specify a file or directory for the source code.
  source_path = "${path.module}/files/index.js"

  // Attach a policy.
  attach_policy = true
  policy        = "${data.aws_iam_policy_document.lambda.json}"

  // Add a dead letter queue.
  attach_dead_letter_config = false

  // Add environment variables.
  environment {
    variables {
      SLACK_PATH = "${var.slack_path}"
      SLACK_CHANNEL_NAME = "${var.slack_channel_name}"
    }
  }

  // Deploy into a VPC.
  attach_vpc_config = false
}