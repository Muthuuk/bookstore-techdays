#! /bin/bash

#
# Due to the GitHub repository being able to build and create extra cloud
# resources that Terraform is blind to, we need to remove these before
# a terraform destroy activity can be processed.
#
# Using Ansible here to discover and remove any existing web apps.
#

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Encode JSON payload in base64 to prevent issues passing it through
TERRAFORM_PARAMETERS_B64=`echo "${TERRAFORM_PARAMETERS}" | base64`

docker run \
  -v $DIR/ansible:/ansible \
  -w /ansible \
  -e AZURE_CLIENT_ID="${ARM_CLIENT_ID}" \
  -e AZURE_SECRET="${ARM_CLIENT_SECRET}" \
  -e AZURE_SUBSCRIPTION_ID="${ARM_SUBSCRIPTION_ID}" \
  -e AZURE_TENANT="${ARM_TENANT_ID}" \
  -e TERRAFORM_PARAMETERS_B64="${TERRAFORM_PARAMETERS_B64}" \
  ghcr.io/octodemo/container-ansible-development:base-20210217 \
  ./destroy_azure_apps.yml \
  -vvv
