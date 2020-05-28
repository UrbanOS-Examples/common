module "security" {
  source = "git@github.com:SmartColumbusOS/scos-tf-security.git?ref=1.1.1"

  force_destroy_s3_bucket = "${var.force_destroy_s3_bucket}"
  alert_handler_sns_topic_arn = "${module.monitoring.alert_handler_sns_topic_arn}"
}