# The enabled_features variable is interpreted by `tf-init` to enable different features by copying them
#   into the root working directory
# If you change the list of enabled features, or if you switch to a different environment
# whose list of enabled_features is different, you must re-run `tf-init` before any other terraform commands.
enabled_features = ["ambari", "cloudbreak", "hive"]

role_arn = "arn:aws:iam::073132350570:role/jenkins_role"

vpc_cidr = "10.100.0.0/16"

ckan_db_snapshot_id = "arn:aws:rds:us-west-2:073132350570:snapshot:ckan-2018-09-24-12-10"

cloudbreak_db_multi_az = false
ambari_db_multi_az = false
hive_db_multi_az = false

cloudbreak_db_apply_immediately = true
ambari_db_apply_immediately = true
hive_db_apply_immediately = true

joomla_backup_file_name = "site-www.dev.internal.smartcolumbusos.com-20180921-095355edt.zip"
