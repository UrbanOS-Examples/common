#!/usr/bin/env bash
set -e

thumbprint=$(
  echo | \
    openssl s_client -servername oidc.eks.${1}.amazonaws.com -connect oidc.eks.${1}.amazonaws.com:443 2>&- | \
    sed -n '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p' | \
    openssl x509 -fingerprint -noout | \
    sed 's/://g' | awk -F= '{print tolower($2)}'
)
thumbprint_json="{\"thumbprint\": \"${thumbprint}\"}"

echo $thumbprint_json