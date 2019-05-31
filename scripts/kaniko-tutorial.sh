#!/usr/bin/env bash
set -e

[[ -n $DEBUG ]] && set -o xtrace

if [[ -z "$DOCKER_HUB_USERNAME" ]]
then
  echo 'The environment variable DOCKER_HUB_USERNAME must be set.'
  exit 1
fi

readonly GIT_TOPLEVEL=$(git rev-parse --show-toplevel 2> /dev/null)
readonly NAMESPACE=kaniko-tutorial

# Deploy the all the components needed
if ! kubectl get namespace "$NAMESPACE" >/dev/null 2>&1
then
  kubectl create namespace "$NAMESPACE"
fi

kubectl create secret generic kaniko-secret --from-file="config.json" -n "$NAMESPACE"

sed -e "s/{{DOCKER_HUB_USERNAME}}/$DOCKER_HUB_USERNAME/" \
  "${GIT_TOPLEVEL}"/pipeline-elastic/samples/02-kaniko-push-dockerhub/* \
  | kubectl apply -f -


