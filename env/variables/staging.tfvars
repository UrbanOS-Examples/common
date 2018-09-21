# The enabled_features variable is interpreted by `tf-init` as a space-separated list. Eg. "featureA featureB featureC"
# If you change the list of enabled features, or if you switch to a different environment
# whose list of enabled_features is different, you must re-run `tf-init` before any other terraform commands.
enabled_features = "ambari cloudbreak hive"

vpc_name = "test"

role_arn = "arn:aws:iam::647770347641:role/jenkins_role"

vpc_cidr = "10.180.0.0/16"

joomla_backup_file_name = "site-www.staging.internal.smartcolumbusos.com-20180921-135800edt.zip"

cloudbreak_db_apply_immediately = true
ambari_db_apply_immediately = true
hive_db_apply_immediately = true
