resource "aws_inspector_assessment_target" "inspector_target" {
  name = "inspector-target"
}

resource "aws_inspector_assessment_template" "inspector_template" {
  name       = "inspector-template"
  target_arn = "${aws_inspector_assessment_target.inspector_target.arn}"
  duration   = "${var.inspector_assessment_duration}"

  rules_package_arns = "${var.inspector_assessment_rules_package_arns}"
}

data "aws_iam_policy_document" "inspector_event_policy_document" {
  statement {
    sid = "StartAssessment"
    actions = [
      "inspector:StartAssessmentRun",
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role" "inspector_event_role" {
  name  = "inspector-event-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "inspector_event_policy" {
  name   = "inspector-event-policy"
  role   = "${aws_iam_role.inspector_event_role.id}"
  policy = "${data.aws_iam_policy_document.inspector_event_policy_document.json}"
}

resource "aws_cloudwatch_event_rule" "inspector_event_schedule" {
  name                = "inspector-schedule"
  description         = "Trigger an Inspector Assessment"
  schedule_expression = "${var.inspector_assessment_schedule_expression}"
}

resource "aws_cloudwatch_event_target" "inspector_event_target" {
  rule     = "${aws_cloudwatch_event_rule.inspector_event_schedule.name}"
  arn      = "${aws_inspector_assessment_template.inspector_template.arn}"
  role_arn = "${aws_iam_role.inspector_event_role.arn}"
}

variable "inspector_assessment_rules_package_arns" {
  description = "Rules packages to be used for assessment"
  default     = [
    "arn:aws:inspector:us-west-2:758058086616:rulespackage/0-9hgA516p",
    "arn:aws:inspector:us-west-2:758058086616:rulespackage/0-H5hpSawc",
    "arn:aws:inspector:us-west-2:758058086616:rulespackage/0-rD1z6dpl",
    "arn:aws:inspector:us-west-2:758058086616:rulespackage/0-JJOtZiqQ"
  ]
}

variable "inspector_assessment_duration" {
  description = "Allowed duration of assessment in seconds"
  default     = 3600
}

variable "inspector_assessment_schedule_expression" {
  description = "Inspector assessment schedule"
  default     = "cron(0 0 15 * ? *)"
}
