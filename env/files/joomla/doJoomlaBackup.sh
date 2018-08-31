#!/bin/bash

s3_bucket=${1}

sudo /usr/bin/php /home/admin/web/public_html/cli/akeeba-backup.php
aws s3 cp /home/admin/web/public_html/administrator/components/com_akeeba/backup/site-*.zip s3://${s3_bucket}/
if [ $? -eq 0 ]; then
    sudo rm -rf /home/admin/web/public_html/administrator/components/com_akeeba/backup/site-*.zip
else
    logger "ERROR >>> Failed to upload Joomla Backup to S3"
fi