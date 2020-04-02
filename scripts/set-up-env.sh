#!/usr/bin/env bash
set -e

[[ -n $DEBUG ]] && set -o xtrace

readonly GIT_TOPLEVEL=$(git rev-parse --show-toplevel 2> /dev/null)

source "${GIT_TOPLEVEL}/scripts/tekton-utils.sh"

# Create the namespace where the pods will be deployed
NAMESPACE="tekton-pipelines"
kubectl create namespace "${NAMESPACE}"
kubectl create namespace tutorials
kubectl apply -f "${GIT_TOPLEVEL}/config"

TEKTON_PIPELINE_VERSION="0.10.1"
ELASTIC_HELM_CHARTS_VERSION="7.6.2"
ELASTIC_IMAGE_VERSION="7.6.2"

# install Elastic Stack with Helm 2.16
helm init || true
helm repo update
helm install --name elasticsearch elastic/elasticsearch --version ${ELASTIC_HELM_CHARTS_VERSION} --set imageTag=${ELASTIC_IMAGE_VERSION} --namespace ${NAMESPACE} --values "${GIT_TOPLEVEL}"/config/helm-charts/elasticsearch.yaml --wait --timeout=900
helm install --name filebeat elastic/filebeat --version ${ELASTIC_HELM_CHARTS_VERSION} --set imageTag=${ELASTIC_IMAGE_VERSION} --namespace ${NAMESPACE} --values "${GIT_TOPLEVEL}"/config/helm-charts/filebeat.yaml
helm install --name metricbeat elastic/metricbeat --version ${ELASTIC_HELM_CHARTS_VERSION} --set imageTag="${ELASTIC_IMAGE_VERSION}" --namespace ${NAMESPACE} --values "${GIT_TOPLEVEL}"/config/helm-charts/metricbeat.yaml
helm install --name kibana elastic/kibana --version ${ELASTIC_HELM_CHARTS_VERSION} --set imageTag=${ELASTIC_IMAGE_VERSION} --namespace ${NAMESPACE} --values "${GIT_TOPLEVEL}"/config/helm-charts/kibana.yaml --wait --timeout=900

# Execute some PipelineRuns and TaskRuns
run_tekton_examples "${TEKTON_PIPELINE_VERSION}" "tutorials"

echo "Execute the following command to have access to Kibana at http://localhost:5601"
echo "kubectl port-forward deployment/kibana-kibana 5601 -n ${NAMESPACE}"
