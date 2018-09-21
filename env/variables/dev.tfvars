# The enabled_features variable is interpreted by `tf-init` as a space-separated list. Eg. "featureA featureB featureC"
# If you change the list of enabled features, or if you switch to a different environment
# whose list of enabled_features is different, you must re-run `tf-init` before any other terraform commands.
enabled_features = "ambari cloudbreak hive"

role_arn = "arn:aws:iam::073132350570:role/jenkins_role"

vpc_cidr = "10.100.0.0/16"

ckan_db_snapshot_id = "arn:aws:rds:us-west-2:073132350570:snapshot:prod-ckan-snapshot-8-30"

cloudbreak_db_multi_az = false
ambari_db_multi_az = false
hive_db_multi_az = false

joomla_backup_file_name = "site-www.dev.internal.smartcolumbusos.com-20180921-095355edt.zip"
