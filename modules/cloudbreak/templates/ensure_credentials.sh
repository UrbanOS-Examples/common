#!/usr/bin/env bash

declare -r CREDENTIAL_FILE="/tmp/credential.json"

main() {
    local -rx CREDENTIAL_NAME=${1}
    local -rx CREDENTIAL_ROLE_ARN=${2}

    set -eux

    create-credential-file
    until ensure-default-credentials; do sleep 10; done
}

create-credential-file() {
    cat << EOF > ${CREDENTIAL_FILE}
{
    "cloudPlatform": "AWS",
    "description": "Default AWS credentials that allow for most cloud creation tasks.",
    "name": "${CREDENTIAL_NAME}",
    "parameters": {
        "selector": "role-based",
        "roleArn": "${CREDENTIAL_ROLE_ARN}"
    }
}
EOF

    trap "rm -rf ${CREDENTIAL_FILE}" EXIT
}

ensure-default-credentials() {
    cb credential describe --name ${CREDENTIAL_NAME} \
        || cb credential create from-file \
            --cli-input-json ${CREDENTIAL_FILE} \
            --name ${CREDENTIAL_NAME}
}

main "${@}"
