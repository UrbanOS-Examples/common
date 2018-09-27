
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

resource "aws_lambda_permission" "with_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.alert_handler_lambda.function_name}"
  principal     = "sns.amazonaws.com"
  source_arn    = "${aws_sns_topic.alert_handler_sns_topic.arn}"
}

resource "aws_sns_topic" "alert_handler_sns_topic" {
  name = "lambda_alert_topic"
}

resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  topic_arn = "${aws_sns_topic.alert_handler_sns_topic.arn}"
  protocol  = "lambda"
  endpoint  = "${aws_lambda_function.alert_handler_lambda.arn}"
}

//---------ALARMS---------//
resource "aws_cloudwatch_metric_alarm" "joomla_high_mem" {
  alarm_name                            = "Joomla - High Memory Utilization"
  comparison_operator                   = "GreaterThanOrEqualToThreshold"
  evaluation_periods                    = "2"
  metric_name                           = "MemoryUtilization"
  namespace                             = "System/Linux"
  period                                = "300"
  statistic                             = "Average"
  threshold                             = "90"
  alarm_actions                         = ["${aws_sns_topic.alert_handler_sns_topic.arn}"]
  dimensions {
    InstanceId                          = "${data.terraform_remote_state.env_remote_state.joomla_instance_id}"
  }
  treat_missing_data                    = "breaching"
}

resource "aws_cloudwatch_metric_alarm" "ckan_internal_high_cpu" {
  alarm_name                            = "CKAN Internal - High CPU Utilization"
  comparison_operator                   = "GreaterThanOrEqualToThreshold"
  evaluation_periods                    = "2"
  metric_name                           = "CPUUtilization"
  namespace                             = "AWS/EC2"
  period                                = "300"
  statistic                             = "Average"
  threshold                             = "90"
  alarm_actions                         = ["${aws_sns_topic.alert_handler_sns_topic.arn}"]
  dimensions {
    InstanceId                          = "${data.terraform_remote_state.env_remote_state.ckan_internal_instance_id}"
  }
  treat_missing_data                    = "breaching"
}

resource "aws_cloudwatch_metric_alarm" "ckan_internal_high_mem" {
  alarm_name                            = "CKAN Internal - High Memory Utilization"
  comparison_operator                   = "GreaterThanOrEqualToThreshold"
  evaluation_periods                    = "2"
  metric_name                           = "MemoryUtilization"
  namespace                             = "System/Linux"
  period                                = "300"
  statistic                             = "Average"
  threshold                             = "90"
  alarm_actions                         = ["${aws_sns_topic.alert_handler_sns_topic.arn}"]
  dimensions {
    InstanceId                          = "${data.terraform_remote_state.env_remote_state.ckan_internal_instance_id}"
  }
  treat_missing_data                    = "breaching"
}

resource "aws_cloudwatch_metric_alarm" "prod_ckan_rds_high_cpu_util" {
  alarm_name                            = "Production CKAN - RDS High CPU Utilization"
  comparison_operator                   = "GreaterThanOrEqualToThreshold"
  evaluation_periods                    = "2"
  metric_name                           = "CPUUtilization"
  namespace                             = "AWS/RDS"
  period                                = "300"
  statistic                             = "Average"
  threshold                             = "90"
  alarm_actions                         = ["${aws_sns_topic.alert_handler_sns_topic.arn}"]
  dimensions {
    DBInstanceIdentifier                = "${data.terraform_remote_state.env_remote_state.ckan_db_instance_id}"
  }
  treat_missing_data                    = "breaching"
}

resource "aws_cloudwatch_metric_alarm" "ckan_instance_status_check_failed" {
  alarm_name                            = "CKAN - Instance Status Check Failed"
  comparison_operator                   = "GreaterThanThreshold"
  evaluation_periods                    = "1"
  metric_name                           = "StatusCheckFailed_Instance"
  namespace                             = "AWS/EC2"
  period                                = "300"
  statistic                             = "Average"
  threshold                             = "0"
  alarm_actions                         = ["${aws_sns_topic.alert_handler_sns_topic.arn}"]
  dimensions {
    InstanceId                          = "${data.terraform_remote_state.env_remote_state.ckan_external_instance_id}"
  }
  treat_missing_data                    = "breaching"
}

resource "aws_cloudwatch_metric_alarm" "ckan_high_mem" {
  alarm_name                            = "CKAN - High Memory Utilization"
  comparison_operator                   = "GreaterThanOrEqualToThreshold"
  evaluation_periods                    = "2"
  metric_name                           = "MemoryUtilization"
  namespace                             = "System/Linux"
  period                                = "300"
  statistic                             = "Average"
  threshold                             = "90"
  alarm_actions                         = ["${aws_sns_topic.alert_handler_sns_topic.arn}"]
  dimensions {
    InstanceId                          = "${data.terraform_remote_state.env_remote_state.ckan_external_instance_id}"
  }
  treat_missing_data                    = "breaching"
}

resource "aws_cloudwatch_metric_alarm" "ckan_high_cpu" {
  alarm_name                            = "CKAN - High CPU Utilization"
  comparison_operator                   = "GreaterThanOrEqualToThreshold"
  evaluation_periods                    = "2"
  metric_name                           = "CPUUtilization"
  namespace                             = "AWS/EC2"
  period                                = "300"
  statistic                             = "Average"
  threshold                             = "90"
  alarm_actions                         = ["${aws_sns_topic.alert_handler_sns_topic.arn}"]
  dimensions {
    InstanceId                          = "${data.terraform_remote_state.env_remote_state.ckan_external_instance_id}"
  }
  treat_missing_data                    = "breaching"
}

resource "aws_cloudwatch_metric_alarm" "ckan_internal_instance_status_check_failed" {
  alarm_name                            = "CKAN Internal - Instance Status Check Failed"
  comparison_operator                   = "GreaterThanThreshold"
  evaluation_periods                    = "1"
  metric_name                           = "StatusCheckFailed_Instance"
  namespace                             = "AWS/EC2"
  period                                = "300"
  statistic                             = "Average"
  threshold                             = "0"
  alarm_actions                         = ["${aws_sns_topic.alert_handler_sns_topic.arn}"]
  dimensions {
    InstanceId                          = "${data.terraform_remote_state.env_remote_state.ckan_internal_instance_id}"
  }
  treat_missing_data                    = "breaching"
}

resource "aws_cloudwatch_metric_alarm" "prod_kong_rds_free_storage_space_low" {
  alarm_name                            = "Production Kong - RDS Free Storage Space Low"
  comparison_operator                   = "LessThanOrEqualToThreshold"
  evaluation_periods                    = "2"
  metric_name                           = "FreeStorageSpace"
  namespace                             = "AWS/RDS"
  period                                = "300"
  statistic                             = "Average"
  threshold                             = "15000000000"
  alarm_actions                         = ["${aws_sns_topic.alert_handler_sns_topic.arn}"]
  dimensions {
    DBInstanceIdentifier                = "${data.terraform_remote_state.env_remote_state.kong_db_instance_id}"
  }
  treat_missing_data                    = "breaching"
}

resource "aws_cloudwatch_metric_alarm" "prod_kong_rds_high_cpu_util" {
  alarm_name                            = "Production Kong - RDS High CPU Utilization"
  comparison_operator                   = "GreaterThanOrEqualToThreshold"
  evaluation_periods                    = "2"
  metric_name                           = "CPUUtilization"
  namespace                             = "AWS/RDS"
  period                                = "300"
  statistic                             = "Average"
  threshold                             = "90"
  alarm_actions                         = ["${aws_sns_topic.alert_handler_sns_topic.arn}"]
  dimensions {
    DBInstanceIdentifier                = "${data.terraform_remote_state.env_remote_state.kong_db_instance_id}"
  }
  treat_missing_data                    = "breaching"
}

resource "aws_cloudwatch_metric_alarm" "kong_high_mem" {
  alarm_name                            = "Kong - High Memory Utilization"
  comparison_operator                   = "GreaterThanOrEqualToThreshold"
  evaluation_periods                    = "2"
  metric_name                           = "MemoryUtilization"
  namespace                             = "System/Linux"
  period                                = "300"
  statistic                             = "Average"
  threshold                             = "90"
  alarm_actions                         = ["${aws_sns_topic.alert_handler_sns_topic.arn}"]
  dimensions {
    InstanceId                          = "${data.terraform_remote_state.env_remote_state.kong_instance_id}"
  }
  treat_missing_data                    = "breaching"
}

resource "aws_cloudwatch_metric_alarm" "kong_instance_status_check_failed" {
  alarm_name                            = "Kong - Instance Status Check Failed"
  comparison_operator                   = "GreaterThanThreshold"
  evaluation_periods                    = "1"
  metric_name                           = "StatusCheckFailed_Instance"
  namespace                             = "AWS/EC2"
  period                                = "300"
  statistic                             = "Average"
  threshold                             = "0"
  alarm_actions                         = ["${aws_sns_topic.alert_handler_sns_topic.arn}"]
  dimensions {
    InstanceId                          = "${data.terraform_remote_state.env_remote_state.kong_instance_id}"
  }
  treat_missing_data                    = "breaching"
}

resource "aws_cloudwatch_metric_alarm" "kong_high_cpu" {
  alarm_name                            = "Kong - High CPU Utilization"
  comparison_operator                   = "GreaterThanOrEqualToThreshold"
  evaluation_periods                    = "2"
  metric_name                           = "CPUUtilization"
  namespace                             = "AWS/EC2"
  period                                = "300"
  statistic                             = "Average"
  threshold                             = "90"
  alarm_actions                         = ["${aws_sns_topic.alert_handler_sns_topic.arn}"]
  dimensions {
    InstanceId                          = "${data.terraform_remote_state.env_remote_state.kong_instance_id}"
  }
  treat_missing_data                    = "breaching"
}

resource "aws_cloudwatch_metric_alarm" "prod_joomla_rds_free_storage_space_low" {
  alarm_name                            = "Production Joomla - RDS Free Storage Space Low"
  comparison_operator                   = "LessThanOrEqualToThreshold"
  evaluation_periods                    = "2"
  metric_name                           = "FreeStorageSpace"
  namespace                             = "AWS/RDS"
  period                                = "300"
  statistic                             = "Average"
  threshold                             = "15000000000"
  alarm_actions                         = ["${aws_sns_topic.alert_handler_sns_topic.arn}"]
  dimensions {
    DBInstanceIdentifier                = "${data.terraform_remote_state.env_remote_state.joomla_db_instance_id}"
  }
  treat_missing_data                    = "breaching"
}

resource "aws_cloudwatch_metric_alarm" "prod_joomla_rds_high_cpu_util" {
  alarm_name                            = "Production Joomla - RDS High CPU Utilization"
  comparison_operator                   = "GreaterThanOrEqualToThreshold"
  evaluation_periods                    = "2"
  metric_name                           = "CPUUtilization"
  namespace                             = "AWS/RDS"
  period                                = "300"
  statistic                             = "Average"
  threshold                             = "90"
  alarm_actions                         = ["${aws_sns_topic.alert_handler_sns_topic.arn}"]
  dimensions {
    DBInstanceIdentifier                = "${data.terraform_remote_state.env_remote_state.joomla_db_instance_id}"
  }
  treat_missing_data                    = "breaching"
}

resource "aws_cloudwatch_metric_alarm" "prod_scos_elb_no_healthy_hosts" {
  alarm_name                            = "Prod SCOS Elb - No Healthy Hosts"
  comparison_operator                   = "LessThanOrEqualToThreshold"
  evaluation_periods                    = "2"
  metric_name                           = "HealthyHostCount"
  namespace                             = "AWS/ApplicationELB"
  period                                = "300"
  statistic                             = "Average"
  threshold                             = "0"
  alarm_actions                         = ["${aws_sns_topic.alert_handler_sns_topic.arn}"]
  dimensions {
    TargetGroup                         = "${module.load_balancer_public.target_group_arn_suffix["${terraform.workspace}-Joomla"]}",
    LoadBalancer                        = "${module.load_balancer_public.lb_arn_suffix}"
  }
  treat_missing_data                    = "breaching"
}

resource "aws_cloudwatch_metric_alarm" "prod_ckan_rds_free_storage_space_low" {
  alarm_name                            = "Production CKAN - RDS Free Storage Space Low"
  comparison_operator                   = "LessThanOrEqualToThreshold"
  evaluation_periods                    = "2"
  metric_name                           = "FreeStorageSpace"
  namespace                             = "AWS/RDS"
  period                                = "300"
  statistic                             = "Average"
  threshold                             = "15000000000"
  alarm_actions                         = ["${aws_sns_topic.alert_handler_sns_topic.arn}"]
  dimensions {
    DBInstanceIdentifier                = "${data.terraform_remote_state.env_remote_state.ckan_db_instance_id}"
  }
  treat_missing_data                    = "breaching"
}
resource "aws_cloudwatch_metric_alarm" "joomla_high_cpu" {
  alarm_name                            = "Joomla - High CPU Utilization"
  comparison_operator                   = "GreaterThanOrEqualToThreshold"
  evaluation_periods                    = "2"
  metric_name                           = "CPUUtilization"
  namespace                             = "AWS/EC2"
  period                                = "300"
  statistic                             = "Average"
  threshold                             = "90"
  alarm_actions                         = ["${aws_sns_topic.alert_handler_sns_topic.arn}"]
  dimensions {
    InstanceId                          = "${data.terraform_remote_state.env_remote_state.joomla_instance_id}"
  }
  treat_missing_data                    = "breaching"
}

resource "aws_cloudwatch_metric_alarm" "joomla_instance_status_check_failed" {
  alarm_name                            = "Joomla - Instance Status Check Failed"
  comparison_operator                   = "GreaterThanThreshold"
  evaluation_periods                    = "1"
  metric_name                           = "StatusCheckFailed_Instance"
  namespace                             = "AWS/EC2"
  period                                = "300"
  statistic                             = "Average"
  threshold                             = "0"
  alarm_actions                         = ["${aws_sns_topic.alert_handler_sns_topic.arn}"]
  dimensions {
    InstanceId                          = "${data.terraform_remote_state.env_remote_state.joomla_instance_id}"
  }
  treat_missing_data                    = "breaching"
}

resource "aws_cloudwatch_metric_alarm" "watchintor_cota_streaming_consumer_open_connection_failed" {
  alarm_name                            = "Watchinator - Cota Streaming Consumer Open Connection Failed"
  comparison_operator                   = "LessThanThreshold"
  evaluation_periods                    = "1"
  metric_name                           = "Opened"
  namespace                             = "Socket Connection"
  period                                = "120"
  statistic                             = "Sum"
  threshold                             = "1"
  alarm_actions                         = ["${aws_sns_topic.alert_handler_sns_topic.arn}"]
  dimensions {
    ApplicationName                     = "Cota-Streaming-Consumer"
  }
  treat_missing_data                    = "breaching"
}
//-----------------------//

variable "slack_path" {
  description = "Path to the Slack channel"
  default = "/services/T7LRETX4G/BA0EW8W6R/vRbX198LKBkhAEK64OnHCUXH"
}

variable "slack_channel_name" {
  description = "Name of the Slack channel"
}