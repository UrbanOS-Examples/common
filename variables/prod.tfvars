# the enabled_features variable is interpreted by `tf-init` to enable different features by copying them
#   into the root working directory
# if you change the list of enabled features, or if you switch to a different environment
# whose list of enabled_features is different, you must re-run `tf-init` before any other terraform commands.
enabled_features = ["eks-cluster",
  "joomla",
  "lime_db",
  "cloudwatch_monitoring",
  "redis",
]

role_arn = "arn:aws:iam::374013108165:role/jenkins_role"

vpc_cidr = "10.200.0.0/16"

#DNS
prod_dns_zone = "smartcolumbusos.com"

# Redis Elasticache settings
redis_node_type = "cache.m4.large"

#Alarms
alarms_slack_channel_name = "#prod_alerts"