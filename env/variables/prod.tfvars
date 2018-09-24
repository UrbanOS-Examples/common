# The enabled_features variable is interpreted by `tf-init` as a space-separated list. Eg. "featureA featureB featureC"
# If you change the list of enabled features, or if you switch to a different environment
# whose list of enabled_features is different, you must re-run `tf-init` before any other terraform commands.
enabled_features = ""

role_arn = "arn:aws:iam::374013108165:role/jenkins_role"

vpc_cidr = "10.200.0.0/16"

prod_dns_zone = "smartcolumbusos.com"

joomla_backup_file_name = "site-www.smartcolumbusos.com-20180921-081715edt.zip"

ckan_db_multi_az = true

kong_db_multi_az = true

joomla_db_multi_az = true

ckan_db_snapshot_id = "arn:aws:rds:us-west-2:374013108165:snapshot:rds:prod-production-ckan-2018-09-24-05-00"