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

prod_dns_zone = "smartcolumbusos.com"

skip_final_db_snapshot = false

# Redis Elasticache settings
redis_node_type = "cache.m4.large"

# Lime DB override settings
lime_db_size = "db.t2.small"

lime_db_storage = 100

lime_db_multi_az = true

lime_db_apply_immediately = true

#DNS
is_public_facing = true

alarms_slack_channel_name = "#prod_alerts"