// NOTE: the tags here are pretty dependent on the internals of the EKS feature
locals {
  exclude_ingest_ports_for_eks_workers = {
    "service.action.networkConnectionAction.remotePortDetails.port" = {"Eq" = [255, 8443]},
    "resource.instanceDetails.tags.key" = {"Eq" = ["aws:autoscaling:groupName"]},
    "resource.instanceDetails.tags.value" = {"Eq" = ["${local.kubernetes_cluster_name}-Workers"]}
  }
}
module "security" {
  source = "git@github.com:SmartColumbusOS/scos-tf-security.git?ref=1.3.0"

  force_destroy_s3_bucket     = "${var.force_destroy_s3_bucket}"
  alert_handler_sns_topic_arn = "${module.monitoring.alert_handler_sns_topic_arn}"

  exclusion_rule_count = 1
  exclusion_rules      = [
    {
      name = "exclusion-common-ingestion",
      description = "Exclude alerting on ingestions for non-standard ports on non-kafka EKS workers",
      criterion = "${jsonencode(local.exclude_ingest_ports_for_eks_workers)}"
    }
  ]
}
