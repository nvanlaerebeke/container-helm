#!/bin/sh

export HELM_EXPERIMENTAL_OCI=1

source /functions.sh

case "$1" in
push)
  push 
  ;;
upgrade)
  upgrade "$2"
  ;;
release)
  release "$2" "$3"
  ;;
*)
    echo "Please provide an action (push/upgrade/release)"
    exit 1
  ;;
esac