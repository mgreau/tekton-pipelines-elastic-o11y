#!/usr/bin/env bash
set -e

[[ -n $DEBUG ]] && set -o xtrace

readonly GIT_TOPLEVEL=$(git rev-parse --show-toplevel 2> /dev/null)

source "${GIT_TOPLEVEL}/helpers/tekton-utils.sh"

TEKTON_PIPELINE_VERSION="0.18.1"
ECK_VERSION="1.3.1"

# Install Tekton Pipelines
kubectl apply -f "https://storage.googleapis.com/tekton-releases/pipeline/previous/v${TEKTON_PIPELINE_VERSION}/release.yaml"

# Install ECK
kubectl apply -f https://download.elastic.co/downloads/eck/${ECK_VERSION}/all-in-one.yaml
sleep 20s

# Install Elasticsearch and Kibana
kubectl apply -n "elastic-system" -f "${GIT_TOPLEVEL}/config/eck/monitoring-es-kb.yaml"
sleep 20s

# Install Filebeat and Metricbeat
kubectl apply  -n "elastic-system" -f "${GIT_TOPLEVEL}/config/eck/monitoring-filebeat-metricbeat.yaml"
sleep 20s

echo "***************************************"
echo "        ELASTIC OBSERVABILITY          "
echo "***************************************"
echo "- URL: https://localhost:5601/app/observability/overview"
echo "- user: elastic"
echo "- password: run -> echo $(kubectl get secret -n elastic-system elasticsearch-monitoring-es-elastic-user -o=jsonpath='{.data.elastic}' | base64 --decode) "
# Execute some PipelineRuns and TaskRuns
#run_tekton_examples "${TEKTON_PIPELINE_VERSION}" "default"

kubectl -n elastic-system port-forward svc/kibana-monitoring-kb-http 5601
