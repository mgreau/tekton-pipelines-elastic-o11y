#!/usr/bin/env bash
set -e

[[ -n $DEBUG ]] && set -o xtrace

readonly GIT_TOPLEVEL=$(git rev-parse --show-toplevel 2> /dev/null)
readonly NAMESPACE=kaniko-tutorial

# Deploy the all the components needed
if ! kubectl get namespace "$NAMESPACE" >/dev/null 2>&1
then
  kubectl create namespace "$NAMESPACE"
fi

kubectl create secret generic kaniko-secret --from-file="config.json" -n "$NAMESPACE"

kubectl apply -f "${GIT_TOPLEVEL}/pipeline-elastic/samples/02-kaniko-push-dockerhub"


