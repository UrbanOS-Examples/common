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
  "inspector_assessment",
  "data_science_stack",
  "elasticsearch",
  "security"
]

role_arn = "arn:aws:iam::374013108165:role/jenkins_role"

vpc_cidr = "10.200.0.0/16"

force_destroy_s3_bucket = false

andi_public_sample_datasets = "andi-public-sample-datasets"

# DNS
prod_dns_zone = "smartcolumbusos.com"

# Redis Elasticache settings
redis_node_type = "cache.m4.large"

# Alarms
alarms_slack_path = "/services/T7LRETX4G/BA0EW8W6R/vRbX198LKBkhAEK64OnHCUXH"

alarms_slack_channel_name = "#prod_alerts"

# EKS
key_pair_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC5yJ//U9QiuN3T7C2ZooFRP55is2unoW1O58vKDhn6aHeGaKodQCfWebHiXSQszW+pQjjC3W7SUuLAf6eHNEWc8TbVEmNBEf8mHsgSRMecIMLrCjcDS4dmZ8TUSzHkqh1b2vddn/cb+B7CshTWqhwWfNq/mVYB1iW6zPhukBiFllHF8vt4mHGsmcJ5k8S5FhtoQx3j5bZ8EkSKvGILGYt8BSbFEOGOheikG1DorZZk8EcSvyWLbo7rLksdyqLENSvvfiPZYXYPVez+SIiZMJizlLjZjp+yfzeJ6e0GUsIdQz5TO3Tg5thBtH5VbT0DLIGkqfojwmFJpHfSCsYKi+qD76PEEsaOc+GEjDZVuY3YEYcwWfAFxCOgsxReoDX22m9S0M+Nr7C8s0gLO/wFMkBQFC9fonmAbO498E4X7edDOzrv1Nd3A/mAgTgDC20r+ErS/1jmBNw/FhkMe7pDIFSozbV0xLBF+Ni434S1zyrdClG7k4Cw+gZCmjcyfVJdIIzpzjeTBrlPJ+TXWjbUsHByXGfS6VrHPU40pWAiVbWbiY9OUAWsunOlsunzYUUDNFPgJasa6T8HFndiUNk3v0jjq77Uz7Ppp9ucbNf0ibvN+q+mux+rse9g5/8ScBpBTHwaT5efY70hsAYa7PtT74g30NRmhw+E28mi5x68i5wGrQ== jarred.olson@AMAC02XR4Z3JG5M"

key_pair_name = "eks_key_prod_2020_03_23"

max_num_of_workers = 16
min_num_of_workers = 16

max_num_of_memory_workers = 4
min_num_of_memory_workers = 4