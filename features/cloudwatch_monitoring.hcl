module "monitoring" {
  source = "git@github.com:SmartColumbusOS/scos-tf-monitoring.git?ref=1.0.2"

  alarms_slack_channel_name = "${var.alarms_slack_channel_name}"
  alarms_slack_path         = "${var.alarms_slack_path}"
}

//---------ALARMS---------//

resource "aws_cloudwatch_metric_alarm" "joomla_rds_free_storage_space_low" {
  count               = "${var.joomla_alarms_enabled}"
  alarm_name          = "${terraform.workspace} Joomla - RDS Free Storage Space Low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "15000000000"
  alarm_actions       = ["${module.monitoring.alert_handler_sns_topic_arn}"]

  dimensions {
    DBInstanceIdentifier = "${module.joomla_db.id}"
  }

  treat_missing_data = "breaching"
}

resource "aws_cloudwatch_metric_alarm" "joomla_rds_high_cpu_util" {
  count               = "${var.joomla_alarms_enabled}"
  alarm_name          = "${terraform.workspace} Joomla - RDS High CPU Utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "90"
  alarm_actions       = ["${module.monitoring.alert_handler_sns_topic_arn}"]

  dimensions {
    DBInstanceIdentifier = "${module.joomla_db.id}"
  }

  treat_missing_data = "breaching"
}

resource "aws_cloudwatch_metric_alarm" "watchintor_cota_streaming_consumer_open_connection_failed" {
  alarm_name          = "${terraform.workspace} Watchinator - Cota Streaming Consumer Open Connection Failed"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "Opened"
  namespace           = "Socket Connection"
  period              = "120"
  statistic           = "Sum"
  threshold           = "1"
  alarm_actions       = ["${module.monitoring.alert_handler_sns_topic_arn}"]

  dimensions {
    ApplicationName = "Cota-Streaming-Consumer"
  }

  treat_missing_data = "breaching"
}

//-----------------------//

variable "alarms_slack_path" {
  description = "Path to the Slack channel for monitoring alarms"
}

variable "alarms_slack_channel_name" {
  description = "Name of the Slack channel for monitoring alarms"
}

variable "joomla_alarms_enabled" {
  description = "Enables Joomla Cloudwatch alarms. Defaults to true."
  default     = true
}