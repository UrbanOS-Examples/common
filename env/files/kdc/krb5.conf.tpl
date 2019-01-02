# Configuration snippets may be placed in this directory as well
includedir /etc/krb5.conf.d/

[logging]
 default = FILE:/var/log/krb5libs.log
 kdc = FILE:/var/log/krb5kdc.log
 admin_server = FILE:/var/log/kadmind.log

[libdefaults]
 dns_lookup_realm = false
 ticket_lifetime = 24h
 renew_lifetime = 7d
 forwardable = true
 rdns = false
 pkinit_anchors = /etc/pki/tls/certs/ca-bundle.crt
 default_realm = ${KDC_DOMAIN}
 default_ccache_name = KEYRING:persistent:%{uid}

[realms]
 ${KDC_DOMAIN} = {
 kdc = KDC-A.${KDC_DOMAIN}
 admin_server = KDC-A.${KDC_DOMAIN}
 }

[domain_realm]
 .${KDC_DOMAIN} = ${KDC_DOMAIN}
 ${KDC_DOMAIN} = ${KDC_DOMAIN}