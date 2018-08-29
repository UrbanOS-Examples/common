role_arn = "arn:aws:iam::374013108165:role/jenkins_role"

vpc_cidr = "10.200.0.0/16"

### These variables should ONLY be specified in PROD, and they are necessary to get the correct TLS certificate behavior.
tls_certificate_dns_name_override = "smartcolumbusos.com"
tls_certificate_public_hosted_zone_id_override = "ZE5NAJ4YWJFBA"
