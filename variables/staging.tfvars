# the enabled_features variable is interpreted by `tf-init` to enable different features by copying them
#   into the root working directory
# if you change the list of enabled features, or if you switch to a different environment
# whose list of enabled_features is different, you must re-run `tf-init` before any other terraform commands.
enabled_features = ["eks-cluster",
  "joomla",
  "lime_db",
  "cloudwatch_monitoring",
  "redis",
  "ses",
]

vpc_name = "test"

role_arn = "arn:aws:iam::647770347641:role/jenkins_role"

vpc_cidr = "10.180.0.0/16"

# Redis Elasticache settings
redis_node_type = "cache.m4.large"

#DNS
root_dns_zone = "staging-smartos.com"

#Alarms
alarms_slack_path = "/services/T7LRETX4G/BDE8Y9SQ3/Amboqt9U8R3IYQgxUlBPkSUY"

alarms_slack_channel_name = "#pre_prod_alerts"

key_pair_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC3OKNBcNl3JuHcG0L77Z1IWar4VOw3dgs6VeP7IFN7mPCnajZQTvEbsWhvYuqBfcZjNz5Yfhzx8qNwrJrILZwebAyNxYJX5OPF6HB16yFVmAc8KEf9oywXy7JjPXIfJKID3ouDC/yp0qSLntMKzj/K81SnKz+jevntXARFNpXNf/34bZ8tzo6byHMGxLDVuhA/eWH6dsPXejNblGX3sZZA4s97zG0JsyMDGZH972TTrFENcIO5fBx+dMcngOw0o9lxja5usjzotZh5O7iINJQROF8FkzDKSB8E0Mwt7S8nawx5wKDTobyoEQns6OyiwHgqwPU++SmIyc+aZSWTt6TkoYe2PXdi7ksp0os7c916Ms2Bod7kon5l5cdKWDMR7+v98gDn3COyL0YSnjy5zXPUsJ3z3L4zJnm0U0IXfKsgxAZmEFGO70w+PglkAyCBDwKhoQt4ZFwbffTFCn3/W1i2UkfKSf9tL7Q9US/sOVocPTYlssT71OkM3zrPTEsdCr+Hb7sOqRsAwI9omM2EhEnBio4yVOnxwQlhZfEHGU47HbSi4z2W5HOzr4bVxhvDcQ8OHqwagO9R1x+U78qaSCJkZ27oAldGbR2uFp6ozpFb0W4fTFMrNTijuLSLjuJvY5GAkQNCKdgCHB/rBI4rd+uvkP9KaWhw91EELoKON/x5iQ== oasis@SmartCity01.local"

key_pair_name = "eks_key_staging_20200203"
