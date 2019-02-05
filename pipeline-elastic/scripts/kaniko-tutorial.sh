#!/usr/bin/env bash
set -e

[[ -n $DEBUG ]] && set -o xtrace

readonly GIT_TOPLEVEL=$(git rev-parse --show-toplevel 2> /dev/null)

# Deploy the all the components needed
INIT="$1"
if [[ -z "$INIT" ]]
then
  kubectl delete namespace kaniko-tutorial
fi

kubectl create namespace kaniko-tutorial
kubectl create secret generic kaniko-secret --from-file="${HOME}/.docker/config.json" -n kaniko-tutorial

kubectl apply -f "${GIT_TOPLEVEL}/pipeline-elastic/samples/03-kaniko-push-dockerhub"


