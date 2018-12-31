#!/usr/bin/env bash

kdc_domain= 
kdc_admin_password=
kdc_hostname=
kdc_master_database_password=

until [ ${#} -eq 0 ]; do
    case "${1}" in
        --kdc-domain)
            kdc_domain=${2}
            shift
            ;;
        --kdc-admin-password)
            kdc_admin_password=${2}
            shift
            ;;
        --kdc-hostname)
            kdc_hostname=${2}
            shift
            ;;
        --kdc-master-database-password)
            kdc_master_database_password=${2}
            shift
            ;;
    esac
    shift
done

yum install -y krb5-server krb5-workstation pam_krb5

cp /tmp/krb5.conf /etc/krb5.conf
cp /tmp/kdc.conf /var/kerberos/krb5kdc/kdc.conf
echo "*/admin@${kdc_domain} *" > /var/kerberos/krb5kdc/kadm5.acl

kdb5_util create -s -r ${kdc_domain} -P {$kdc_master_database_password}
systemctl start krb5kdc kadmin
systemctl enable krb5kdc kadmin

#create principals
kadmin.local addprinc -pw ${kdc_admin_password} root/admin
kadmin.local addprinc -randkey host/${kdc_hostname}.${kdc_domain}
kadmin.local ktadd host/${kdc_hostname}.${kdc_domain}