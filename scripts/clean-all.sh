#!/usr/bin/env bash
set -e

[[ -n $DEBUG ]] && set -o xtrace

readonly GIT_TOPLEVEL=$(git rev-parse --show-toplevel 2> /dev/null)

NAMESPACES="tutorials elastic-stack tekton-pipelines"

for NAMESPACE in $NAMESPACES
do
  if kubectl get namespace $NAMESPACE; then
    kubectl delete namespace $NAMESPACE
  fi
done

kubectl delete namespace elastic-stack
kubectl delete namespace tekton-pipelines







