#!/bin/bash
set -ex


UNAVAILABLE_MESSAGE=$(cat <<-END
You have added the **Activate Bitrise Build Cache for Bazel** add-on step to your workflow.

However, it has not been activated for this workspace yet. Please contact [support@bitrise.io](mailto:support@bitrise.io) to activate it.
Build cache is not activated in this build.
END
)

if [ "$BITRISEIO_BUILD_CACHE_ENABLED" != "true" ]; then
  printf "\n%s\n" "$UNAVAILABLE_MESSAGE"
  bitrise :annotation annotate "$UNAVAILABLE_MESSAGE" --style error || {
    echo "Failed to create annotation"
    exit 0
  }
  exit 0
fi


case "${BITRISE_DEN_VM_DATACENTER}" in
LAS1)
export BITRISE_CACHE_ENDPOINT=grpc://las-cache.services.bitrise.io:6666
;;
ATL1)
export BITRISE_CACHE_ENDPOINT=grpc://atl-cache.services.bitrise.io:6666
;;
*)
export BITRISE_CACHE_ENDPOINT=grpcs://pluggable.services.bitrise.io
;;
esac


echo "Configuring Bitrise remote cache..."
envman add --key BITRISE_CACHE_ENDPOINT --value "$BITRISE_CACHE_ENDPOINT"

