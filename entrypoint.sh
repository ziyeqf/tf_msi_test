#!/bin/sh
set -eu

export ARM_USE_MSI=true

if [ -n "${IDENTITY_ENDPOINT:-}" ] && [ -z "${ARM_MSI_ENDPOINT:-}" ]; then
  export ARM_MSI_ENDPOINT="$IDENTITY_ENDPOINT"
fi

export ARM_MSI_API_VERSION="${ARM_MSI_API_VERSION:-2019-08-01}"

terraform init -input=false
exec terraform plan -input=false
