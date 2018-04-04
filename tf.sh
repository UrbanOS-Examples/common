#!/bin/bash
#Simple Terraform wrapper that ensures the command is run within a valid workspace

set -e
set -o pipefail

if [ ${#@} == 0 ]; then
    printf "Usage: $0 workspace [other_params]\n"
    printf "\tworkspace -  Terraform workspace. Run terraform workspace list for list of workspaces\n"
    printf "\tother_params -  Parameters that are passed dirrectly to Terraform\n"
    exit 1
fi

WORKSPACE=$1

terraform workspace select $WORKSPACE

exec "terraform" "${@:2}" -var-file=variables/"$WORKSPACE.tfvars"
