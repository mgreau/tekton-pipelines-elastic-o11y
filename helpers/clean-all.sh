#!/usr/bin/env bash
set -e

[[ -n $DEBUG ]] && set -o xtrace

TEKTON_PIPELINE_VERSION="0.18.1"
ECK_VERSION="1.3.1"
NAMESPACES="elastic-system tekton-pipelines"

# cleanup examples
tkn tr delete --all --force -n "default" && tkn pr delete --all --force -n "default"

kubectl delete -f "https://storage.googleapis.com/tekton-releases/pipeline/previous/v${TEKTON_PIPELINE_VERSION}/release.yaml" || true

kubectl delete -f https://download.elastic.co/downloads/eck/${ECK_VERSION}/all-in-one.yaml || true

kubectl delete pvc go-source

# cleanup Elastic and Tekton Pipeliens CRDs
for NAMESPACE in $NAMESPACES
do
  if kubectl get namespace "${NAMESPACE}"; then
    kubectl delete namespace "${NAMESPACE}" || true
  fi
done


