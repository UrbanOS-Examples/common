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

key_pair_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDClmocTRX6u3Nu5Voq8K4dWGV1SK64SrRWXet+yjAwJOCkfYoqbakhQY7MsDl4QijUtOFx6CBREHw5m9XokSyy5qlSsJIF2XALzqmzmUnQHdosP36bOI1fT+uDbjIMk9n2BKDJ6x2tvUgcxnRhNJzw6Ku/riq0TfpAMPsu2Tkr48Q4VJ4/OgvTgnxfpuEJk7IqKMJiJVC0YHaClH8WURTgKpLC2Rg7cMkwIa9aseaOjWj4LaBmJQ32pvinz5+AdFCgnK5Li5nBBd+Pca702EHESXYwpqIn+mwwAG1z61My2vfXx6TfEOeGMa2c5eLniVexPt6OJRCVh+1QuqVcN6Qe6o8fzgCO2ji717iZn7cVg79VanQAJkDxzJ20O9BP9EOvFrnFzem75y9PunO2qUePj/Zms8lPzEAK0/qR+8Q98TbFtWvfbm/HC4T91ajOwk/PYZM6wZadSxmQVo9QNFWJAF7zC4GWX18SVkDtpI8IKzs63esLvNa29sTB2enB62TtRxFyA4iht0268Iz1tSxcH4tD8fzm3JULXs8AlXGVL5tsqnkj9BGBIqCinRmdJXuX/b8gHO5hgXT33Je2gCRRUX9FqYgb3vMGpwoy60nutMQO6qBUt7EN2Yg9AGxhADImIAPTyvij/CTLazLUjjrbZ7zwwX5NXFFzSarMkNmqZQ== smillard@scotts-mbp.lan"

key_pair_name = "eks_key_dev_20200127"
