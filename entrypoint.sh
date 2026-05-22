#!/bin/sh
set -eu

if [ "$#" -eq 0 ]; then
  set -- plan -input=false
fi

if [ "${ARM_USE_MSI:-}" = "true" ] || [ "${ARM_USE_MSI:-}" = "1" ]; then
  if [ -n "${IDENTITY_ENDPOINT:-}" ] && [ -z "${ARM_MSI_ENDPOINT:-}" ]; then
    export ARM_MSI_ENDPOINT="$IDENTITY_ENDPOINT"
  fi

  export ARM_MSI_API_VERSION="${ARM_MSI_API_VERSION:-2019-08-01}"
fi

case "$1" in
  sh|/bin/sh|terraform)
    exec "$@"
    ;;
  version|-version|--version)
    exec terraform "$@"
    ;;
  init)
    exec terraform "$@"
    ;;
esac

if [ "${TF_RUNNER_SKIP_INIT:-}" != "1" ]; then
  terraform init -input=false
fi

exec terraform "$@"
