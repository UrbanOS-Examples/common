#!/bin/bash

#fetch certbot to use lets encrypt
wget https://dl.eff.org/certbot-auto

#generate certificate
chmod +x certbot-auto
./certbot-auto certonly --agree-tos --email scos_alm_account@pillartechnology.com --standalone -d ${dns_name} -n

apt-get update
apt-get install -y nginx

cat <<EOF >/etc/nginx/sites-available/jenkins-relay
server {
  listen 443 ssl;

  server_name ${dns_name};
  ssl_certificate /etc/letsencrypt/live/${dns_name}/fullchain.pem; # managed by Certbot
  ssl_certificate_key /etc/letsencrypt/live/${dns_name}/privkey.pem; # managed by Certbot
  ssl_protocols       TLSv1.1 TLSv1.2;
  ssl_ciphers         HIGH:!aNULL:!MD5;

  location "/" {
    return 403;
  }

  location "/github-webhook" {
    proxy_pass https://${jenkins_host}:${jenkins_port}/github-webhook/;
    proxy_intercept_errors on;
    error_page 301 302 307 = @handle_redirect;

    limit_except POST {
      deny all;
    }
  }

  location @handle_redirect {
    set \$saved_redirect_loc '\$upstream_http_location';
    proxy_pass \$saved_redirect_loc;
  }
}
EOF

cat <<EOF > /usr/bin/cert-renew
#!/usr/bin/env bash
set -xe

sleep \$(( \$RANDOM % 3600 ))
/certbot-auto renew
systemctl reload nginx
EOF
chmod +x /usr/bin/cert-renew

ln -s /etc/nginx/sites-available/jenkins-relay /etc/nginx/sites-enabled/jenkins-relay
rm -rf /etc/nginx/site-available/default

service nginx restart

echo "0 0 * * 0 /usr/bin/cert-renew" > /root/cert-renew.cron
crontab /root/cert-renew.cron
