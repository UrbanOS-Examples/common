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

key_pair_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDWogvs0HtpTLEvkc2PKFQnYHsZPnD4GFm9qTh0qe1JwAjSNpQbp4f3wl6ttdTds/9FHis6sc+Ae7N/moNmTZieoTnWwnrB4eZAFgZU674W+vYUwNMEEsNZ5Xm9M5YVJe0e8qY0mZOfXdQ4PeK0uyI2GFBpvWJeOqXE0zX6OwUUklB14UO0yGowN8jwAn5LleQdEZxcIzhAuzdpVCc03KjsF11tELfe9SsVn5P+hk44DlCRoAvamrPa7ai2pZ+e/yHSYDjhjA3vkVNnq5QjQYf4Am3lkNxYFAyBB/U7seVLls/Vm8ocCwlbaEVM8GHf7w2UgzWCnEd6VgChwinyq1+jTgUwdeXj/uJeTsYItZ67H+j84rwYEd9r2ywk9d3/2ZE/ds7BW+8XT+gZ4f5642WxLMm/vqp3a5O5NQc0qM9pdV7v32z+2qr4umBtbNhbtQWSxLdegTJsDcboB6ttvKciZP5Fcb0Mkwm6lFHfYWi+dVp2E+A422Dft4epVsRru5r+DsFN63IxCsy9VFU0VsiCWLsXAzuCDDkDiz4ULPCIeWwpeAOKVkAdErepmZz/7YEGmPoY257kl1746wl2p3YFU5uuQrTvr5v2MrB2CsSFqe6A5NZp34Xckov7SN3VWnmCp+m3vVJLMYIABcpDaw3+BmFUludyE8f21mKt7ZDiQw== smillard@scotts-mbp.lan"

key_pair_name = "eks_key_staging_20200127"
