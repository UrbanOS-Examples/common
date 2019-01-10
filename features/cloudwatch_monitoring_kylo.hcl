resource "aws_cloudwatch_metric_alarm" "kylo_rds_free_storage_space_low" {
  alarm_name                            = "${terraform.workspace} Kylo - RDS Free Storage Space Low"
  comparison_operator                   = "LessThanOrEqualToThreshold"
  evaluation_periods                    = "2"
  metric_name                           = "FreeStorageSpace"
  namespace                             = "AWS/RDS"
  period                                = "300"
  statistic                             = "Average"
  threshold                             = "${10 * 0.1 * 1000000000}" # Gi * % * bytes
  alarm_actions                         = ["${aws_sns_topic.alert_handler_sns_topic.arn}"]
  dimensions {
    DBInstanceIdentifier                = "${aws_db_instance.kylo.id}"
  }
  treat_missing_data                    = "breaching"
}

resource "aws_cloudwatch_metric_alarm" "kylo_rds_high_cpu_util" {
  alarm_name                            = "${terraform.workspace} Kylo - RDS High CPU Utilization"
  comparison_operator                   = "GreaterThanOrEqualToThreshold"
  evaluation_periods                    = "2"
  metric_name                           = "CPUUtilization"
  namespace                             = "AWS/RDS"
  period                                = "300"
  statistic                             = "Average"
  threshold                             = "90"
  alarm_actions                         = ["${aws_sns_topic.alert_handler_sns_topic.arn}"]
  dimensions {
    DBInstanceIdentifier                = "${aws_db_instance.kylo.id}"
  }
  treat_missing_data                    = "breaching"
}