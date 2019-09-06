#!/usr/bin/env bash
set -e

[[ -n $DEBUG ]] && set -o xtrace

readonly GIT_TOPLEVEL=$(git rev-parse --show-toplevel 2> /dev/null)

# Create the namespace where the pods will be deployed
NAMESPACE="tekton-pipelines"
kubectl create namespace "${NAMESPACE}"
kubectl create namespace tutorials
kubectl apply -f "${GIT_TOPLEVEL}/config"


HELM_CHARTS_VERSION="7.5.2"
IMAGE_VERSION="7.5.2"

# install Elastic Stack with Helm 2.16
helm init || true
helm repo update
helm install --name elasticsearch elastic/elasticsearch --version ${HELM_CHARTS_VERSION} --set imageTag=${IMAGE_VERSION} --namespace ${NAMESPACE} --values "${GIT_TOPLEVEL}"/config/helm-charts/elasticsearch.yaml --wait --timeout=900
helm install --name filebeat elastic/filebeat --version ${HELM_CHARTS_VERSION} --set imageTag=${IMAGE_VERSION} --namespace ${NAMESPACE} --values "${GIT_TOPLEVEL}"/config/helm-charts/filebeat.yaml
helm install --name metricbeat elastic/metricbeat --version ${HELM_CHARTS_VERSION} --set imageTag="${IMAGE_VERSION}" --namespace ${NAMESPACE} --values "${GIT_TOPLEVEL}"/config/helm-charts/metricbeat.yaml
helm install --name kibana elastic/kibana --version ${HELM_CHARTS_VERSION} --set imageTag=${IMAGE_VERSION} --namespace ${NAMESPACE} --values "${GIT_TOPLEVEL}"/config/helm-charts/kibana.yaml --wait --timeout=900

# Execute some TaskRuns
TASKRUNS_EXAMPLES="build-gcs-targz.yaml gcs-resource.yaml pullrequest.yaml task-multiple-output-image.yaml build-gcs-zip.yaml git-resource.yaml secret-env.yaml task-output-image.yaml build-push-kaniko.yaml git-ssh-creds.yaml secret-volume-params.yaml task-volume-args.yaml cloud-event.yaml git-volume.yaml secret-volume.yaml template-volume.yaml clustertask.yaml home-is-set.yaml sidecar-interp.yaml unnamed-steps.yaml configmap.yaml home-volume.yaml sidecar-ready.yaml ps-run-in-order.yaml workspace.yaml docker-creds.yaml pull-private-image.yaml steptemplate-env-merge.yaml"
TASKRUNS_EXAMPLES_URL="https://raw.githubusercontent.com/tektoncd/pipeline/v0.10.0/examples/taskruns/"

for TR in $TASKRUNS_EXAMPLES
do
 kubectl create -f "${TASKRUNS_EXAMPLES_URL}/${TR}" -n default || true
done


kubectl port-forward deployment/kibana-kibana 5601 -n ${NAMESPACE}
open http://localhost:5601


