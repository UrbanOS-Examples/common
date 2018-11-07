# the enabled_features variable is interpreted by `tf-init` to enable different features by copying them
#   into the root working directory
# if you change the list of enabled features, or if you switch to a different environment
# whose list of enabled_features is different, you must re-run `tf-init` before any other terraform commands.
enabled_features = ["eks-cluster",
                    "ckan_shared",
                    "ckan_internal",
                    "ckan_external",
                    "kong",
                    "joomla",
                    "load_balancer",
                    "streaming-data-aggregator",
                    "datalake",
                    "kylo",
                   ]

vpc_name = "test"

role_arn = "arn:aws:iam::647770347641:role/jenkins_role"

ckan_db_snapshot_id = "arn:aws:rds:us-west-2:073132350570:snapshot:ckan-2018-09-24-12-10"

vpc_cidr = "10.180.0.0/16"

joomla_backup_file_name = "site-www.staging.internal.smartcolumbusos.com-20180930-200001edt.zip"

cloudbreak_db_apply_immediately = true
ambari_db_apply_immediately = true
hive_db_apply_immediately = true

# prod is an m4.2xl and m4.xl respectively
# We're at 5% and 14% memory utilization and negligible cpu usage in non-prod environments.
# This works out to a t2.medium being about 2x our actual usage.
ckan_internal_instance_type = "t2.medium"

ckan_internal_instance_ebs_optimized = false

ckan_external_instance_type = "t2.medium"

ckan_external_instance_ebs_optimized = false

#Jupyterhub EKS Workers
min_num_of_jupyterhub_workers=3
max_num_of_jupyterhub_workers=5
