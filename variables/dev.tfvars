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

key_pair_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDQd2oV3vLOury5t51zZnU1aQfqVTJlW/DXkRoSrvbBbIU6Nx9dyMWxU1grwnNBceAZyGGHYcWhCwIBPZzK+XYoLaxsfMH2IKWoeMJJJhEIX8FYyR3/quFugSKQRR4gdihynHg88QP/fxSZuHQphRpYpeQflO31oP61ynSSybPG3M74AVFtBJ2/SLEXq+s4r8Dp1xuv/UT6WdX/BuWSPUxpDxdjJfkuBpHmkKJG8892P0xMt2IDAlHCphALNFnkcq8SfmGZswCZ8ihSMzgHbo1dNF6pY8uwaLWjK2loX1tq/sJ3pvjQJ1z/Jr+VfAAPyrez7+dTr51ZaF3K6nvXRXxsR5jL/owmujfZkcRvOSJUYcIT5tuxmnGQ96GtTcp4/PEdkMe1a6tZ1eU4ZZZhuHoBQPnRccrUUf2trxzsOuB4FZXE07IMPBZHQjCV0LV08lJNgaRJgV86WquBBn02BfPdhvFWfNVBnQkdHK47mw7RhY1Q7Kvuibf/U2en+QlTcK2tkz4vwPNisIMajUe44WTWMgfZZCNqCh6GF3qpV3s2Iv+6x9hp0LIyrPDgjPJuuKq7LAz/Sgn4wFpOtqdFsNMkQ6B+q51qog6+TEXRENWohwBnbLDmpqEFImwVFr/rHXhvsn/fJdQ4njoTeaU0kYUIBNBxBDHV4jL0YkzQ1wrcYw== oasis@SmartCity01.local"

key_pair_name = "eks_key_dev_20200203"
