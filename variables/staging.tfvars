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

vpc_name = "test"

role_arn = "arn:aws:iam::647770347641:role/jenkins_role"

vpc_cidr = "10.180.0.0/16"

#Jupyterhub EKS Workers
min_num_of_jupyterhub_workers=1
max_num_of_jupyterhub_workers=3

skip_final_db_snapshot = true

# Redis Elasticache settings
redis_node_type = "cache.m4.large"

# Lime DB override settings
lime_db_size = "db.t2.small"
lime_db_storage = 20
lime_db_multi_az = false
lime_db_apply_immediately = true

recovery_window_in_days = 0

#DNS
is_public_facing = false

root_dns_zone = "staging-smartos.com"

alarms_slack_path = "/services/T7LRETX4G/BDE8Y9SQ3/Amboqt9U8R3IYQgxUlBPkSUY"

alarms_slack_channel_name = "#pre_prod_alerts"

#KDC

kdc_domain = "OS-KDC.COM"
