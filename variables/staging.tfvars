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

key_pair_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCzjXXBkeSlA0T304GqMXdeSOYeCiMx5qoYvJEQg1LYbKAQjJSw0tmlIWfKtaf7Ym9gGFBhHApKV9FgcH+hmCfypM2gwD2cyP5MHw186U8hv0SWCQ1yQDkA94X3zeK3+8IDziSReM9f7csIcn/z1sJdphAKaGq1mowueItp7QW+wHt1Xe1l5J/szyDUKMsdcs0d8Ee57Jd4Pk6p8vkmP4yETBdNGnabYqVPYuDVdK2EklR2YzgIam+orYQItjoKAC6R/SH+/b7noWQyUrZrS6x57dcDgXu3r63wRykdme5Id0h+ayr+XdybQsrUoaVKEdvVZlC32XVgf5/A0zspCWbL3U0O3+SjyvazCfSQlBA2CEmSVkQLdWULfU6S9P5pt59qc4JOTufOZaabxXgOyVLK79gJOMyYWEERrC/HH6xzVRgVxcy7fpHk5bViKrSgWvYCzeBqfUxZv9OooWJeTRWI7htRnRt3uRo4MI9TApbqE+aOkrQldsL70W4ZYlRjdC4oVxPxTpT6TeoSoVXCfV3quyPgEh5a/1QPkyQvmoc8qFDaXtpAKM2vwMcz/eHCXEqFUioC4r4jxeNZVN+ltWPguL3JSR7VGZJp0LwEFHp2HDCwbIr69HShZe1FZ8zXygZgDhhVK2IXjl+vivVcR9pbwelpZtDWhrapDTxHIDePww== oasis2@MBP-6"

key_pair_name = "eks_key_staging_20200122"
