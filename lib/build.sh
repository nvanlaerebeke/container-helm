#!/bin/sh

export HELM_EXPERIMENTAL_OCI=1

. function.sh

case $1 in
push)
  push 
  ;;
upgrade)
  upgrade
  ;;
*)
    echo "Please provide an action (push/upgrade)"
    exit 1
  ;;
esac