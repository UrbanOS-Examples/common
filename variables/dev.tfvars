# The enabled_features variable is interpreted by `tf-init` to enable different features by copying them
#   into the root working directory
# If you change the list of enabled features, or if you switch to a different environment
# whose list of enabled_features is different, you must re-run `tf-init` before any other terraform commands.
enabled_features = ["eks-cluster",
  "joomla",
  "lime_db",
  "cloudwatch_monitoring",
  "redis",
  "ses",
]

role_arn = "arn:aws:iam::073132350570:role/jenkins_role"

vpc_cidr = "10.100.0.0/16"

# Redis Elasticache settings
redis_node_type = "cache.t2.medium"

#DNS
root_dns_zone = "dev-smartos.com"

#Alarms
alarms_slack_path = "/services/T7LRETX4G/BDE8Y9SQ3/Amboqt9U8R3IYQgxUlBPkSUY"

alarms_slack_channel_name = "#pre_prod_alerts"

#Joomla
joomla_db_instance_class = "db.t3.small"

key_pair_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCfqCqT/eWD0FaguKXYdtjayETz7v8hQQTBaJdHDOGWKM0e3rYx4E4D6oaj4e2QEKUrxJWOvISe81AACEKhLVVIbffgobKV1ymTJ1QnsF/cQkI3rK7mu9H/vVf3Mdw331e/c8wQARkIPtjpB17/sTI15zULZKd34xH57NLr7chUPMT842WxgWK6+lYaAfnVyVbJVNXL6lrCqgJY0gGDN+ZENKxG5gtQmaPtBlF3O9ccKrCpn94RMh8Bax6YFCa2PbaAbZiSGmemlghsu1cpm4SZ6RCH7Z3EVSCLlsPdM8jY+cDOzXX45VgwfJ44YdVXBRz9oS4Xr8tsjXbiv145zrb1bpuMVW0/faBHDFckWLgigvVLutrHYldgOh6MLGfR6/BsjHOMdMWmJMJP/fzs5LNmbB7mmtautZiLMHNydwmMe01zlhgCijguWwF682Qf1d4NuMhq2ocJ6rsXmEdakSYgQd8qNPiUjqh+DjCBxHvfZ+NO8/BrU7Z+sAvltYL7zb5v7DSJ7Gfb/Itr10rP1e9u7ZulFNmq8muSsArFOL3FRzLa+TqcI81jVfwMc8H62XBof2py+1W6ZlUXPKiieNfjUE6SukiQgotKpRFgQPpJljAnbbEcaMTv0AxUVFfY8YGhBJ6bI+/ppTII3gRvJ8tnzfOF/A+XLkIIYsXT3ERFyQ== oasis2@MBP-6"

key_pair_name = "eks_key_dev_20200122"
