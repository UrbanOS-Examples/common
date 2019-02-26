#!/usr/bin/env bash

db_host=
db_user=
db_password=
s3_bucket=
s3_path=
dns_zone=

until [ ${#} -eq 0 ]; do
    case "${1}" in
        --db-host)
            db_host=${2}
            shift
            ;;
        --db-user)
            db_user=${2}
            shift
            ;;
        --db-password)
            db_password=${2}
            shift
            ;;
        --s3-bucket)
            s3_bucket=${2}
            shift
            ;;
        --s3-path)
            s3_path=${2}
            shift
            ;;
        --dns-zone)
            dns_zone=${2}
            shift
            ;;
    esac
    shift
done

set -ex
yum install -y awscli jq

# Clean up joomla webroot to be more generic
rm -rf /home/admin/web/panel.*.smartcolumbusos.com/
if ls -d /home/admin/web/*.smartcolumbusos.com &>/dev/null; then
    mv /home/admin/web/*.smartcolumbusos.com/* /home/admin/web/
    rmdir /home/admin/web/*.smartcolumbusos.com
fi

# Remove old cron jobs
[[ $(crontab -u centos -l) ]] && crontab -u centos -r || true

# Install backup cron job
echo "0 0 * * * admin /usr/bin/php /home/admin/web/public_html/cli/akeeba-backup.php" > /etc/cron.d/joomla_backup

# the cloudwatch metrics collection scripts are baked into our ami
echo "*/5 * * * * centos /home/centos/aws-scripts-mon/mon-put-instance-data.pl --mem-util --disk-space-util --disk-path=/ --from-cron" > /etc/cron.d/cloudwatch

# Restore Joomla from backup
aws s3 cp s3://${s3_bucket}/${s3_path} /tmp/backup.zip
chown -R admin:admin /home/admin/web/public_html
sudo -u admin php /tmp/unite.phar /tmp/scos_unite.xml --debug --log=/tmp | tee /home/centos/unite.log
grep 'Total definitions failed to run        : 0' /home/centos/unite.log
rm -rf /tmp/scos_unite.xml

# Recombobulate Nginx and HTTPD configs
find /etc/nginx/conf.d/ -name '172*' -exec rm {} \;
find /etc/httpd/conf.d/ -name '172*' -exec rm {} \;

rm -f /etc/{httpd,nginx}/conf.d/{vesta,joomla_os}.conf

mv /tmp/joomla_nginx.conf /etc/nginx/conf.d/joomla.conf
mv /tmp/joomla_httpd.conf /etc/httpd/conf.d/joomla.conf

systemctl restart httpd
systemctl restart nginx
systemctl restart crond