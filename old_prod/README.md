Do before a terraform apply or the Joomla! provision will fail.  Note that the old sandbox vpn ssh key, and joomla prod ssh key must be in a known location on the filesystem in order to apply this terraform.

```
ssh-agent
export SSH_AGENT_PID=<pid from ssh-agent command>

ssh-add <path to sandbox-vpn key>
ssh-add <path to prod-joomla>
```

please have desired database password and prodS3ReadOnly AWS credentials readily available


#Production Disaster Recovery Needed Fields

joomla_backup_ami
joomla_backup_file_name
ckan_internal_backup_ami
ckan_rds_snapshot_id
ckan_external_ami
kong_ami
kong_rds_snapshot_id

#Assumptions for Production Disaster Recovery

* VPC exists with the name Prod-VPC
* Bastion/Jump host exists for SSH tunnel
* Keypairs exist in AWS region with correct names
* Snapshots and Ami's exist 
* S3 Bucket for CKAN exists