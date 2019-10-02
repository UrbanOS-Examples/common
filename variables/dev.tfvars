# The enabled_features variable is interpreted by `tf-init` to enable different features by copying them
#   into the root working directory
# If you change the list of enabled features, or if you switch to a different environment
# whose list of enabled_features is different, you must re-run `tf-init` before any other terraform commands.
enabled_features = ["eks-cluster",
                    "joomla",
                    "lime_db",
                    "cloudwatch_monitoring",
                    "redis",
                   ]

role_arn = "arn:aws:iam::073132350570:role/jenkins_role"

vpc_cidr = "10.100.0.0/16"

#Jupyterhub EKS Workers
min_num_of_jupyterhub_workers=1
max_num_of_jupyterhub_workers=2

# Redis Elasticache settings
redis_node_type = "cache.t2.medium"

#DNS
root_dns_zone = "dev-smartos.com"

#Alarms
alarms_slack_path = "/services/T7LRETX4G/BDE8Y9SQ3/Amboqt9U8R3IYQgxUlBPkSUY"
alarms_slack_channel_name = "#pre_prod_alerts"
