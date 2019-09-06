#!/usr/bin/env bash
set -e

[[ -n $DEBUG ]] && set -o xtrace

readonly GIT_TOPLEVEL=$(git rev-parse --show-toplevel 2> /dev/null)

NAMESPACES="tutorials elastic-stack tekton-pipelines"

for NAMESPACE in $NAMESPACES
do
  if kubectl get namespace $NAMESPACE; then
    kubectl delete namespace $NAMESPACE || true
  fi
done

helm del --purge elasticsearch || true
helm del --purge kibana || true
helm del --purge filebeat || true
helm del --purge metricbeat || true





