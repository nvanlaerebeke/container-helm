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
*)
    echo "Please provide an action (push/upgrade)"
    exit 1
  ;;
esac