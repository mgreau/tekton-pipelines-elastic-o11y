#!/usr/bin/env bash
set -e

[[ -n $DEBUG ]] && set -o xtrace

readonly GIT_TOPLEVEL=$(git rev-parse --show-toplevel 2> /dev/null)

# Create the namespace where the pods will be deployed
NAMESPACE="tekton-pipelines"
kubectl create namespace "${NAMESPACE}"
kubectl create namespace tutorials
kubectl apply -f "${GIT_TOPLEVEL}/config"

TEKTON_PIPELINE_VERSION="0.10.1"
ELASTIC_HELM_CHARTS_VERSION="7.5.2"
ELASTIC_IMAGE_VERSION="7.5.2"

# install Elastic Stack with Helm 2.16
helm init || true
helm repo update
helm install --name elasticsearch elastic/elasticsearch --version ${ELASTIC_HELM_CHARTS_VERSION} --set imageTag=${ELASTIC_IMAGE_VERSION} --namespace ${NAMESPACE} --values "${GIT_TOPLEVEL}"/config/helm-charts/elasticsearch.yaml --wait --timeout=900
helm install --name filebeat elastic/filebeat --version ${ELASTIC_HELM_CHARTS_VERSION} --set imageTag=${ELASTIC_IMAGE_VERSION} --namespace ${NAMESPACE} --values "${GIT_TOPLEVEL}"/config/helm-charts/filebeat.yaml
helm install --name metricbeat elastic/metricbeat --version ${ELASTIC_HELM_CHARTS_VERSION} --set imageTag="${ELASTIC_IMAGE_VERSION}" --namespace ${NAMESPACE} --values "${GIT_TOPLEVEL}"/config/helm-charts/metricbeat.yaml
helm install --name kibana elastic/kibana --version ${ELASTIC_HELM_CHARTS_VERSION} --set imageTag=${ELASTIC_IMAGE_VERSION} --namespace ${NAMESPACE} --values "${GIT_TOPLEVEL}"/config/helm-charts/kibana.yaml --wait --timeout=900

# Execute some PipelineRuns and TaskRuns
TASKRUNS_EXAMPLES="taskruns/build-gcs-targz.yaml taskruns/gcs-resource.yaml taskruns/pullrequest.yaml taskruns/task-multiple-output-image.yaml taskruns/build-gcs-zip.yaml taskruns/git-resource.yaml taskruns/secret-env.yaml taskruns/task-output-image.yaml 
                   taskruns/build-push-kaniko.yaml taskruns/git-ssh-creds.yaml taskruns/secret-volume-params.yaml taskruns/task-volume-args.yaml taskruns/git-volume.yaml taskruns/secret-volume.yaml taskruns/template-volume.yaml  taskruns/home-is-set.yaml 
                   taskruns/sidecar-interp.yaml taskruns/unnamed-steps.yaml taskruns/configmap.yaml taskruns/home-volume.yaml taskruns/sidecar-ready.yaml taskruns/steps-run-in-order.yaml taskruns/workspace.yaml taskruns/docker-creds.yaml 
                   taskruns/steptemplate-env-merge.yaml pipelineruns/output-pipelinerun.yaml pipelineruns/conditional-pipelinerun.yaml"
TEKTON_EXAMPLES_URL="https://raw.githubusercontent.com/tektoncd/pipeline/v${TEKTON_PIPELINE_VERSION}/examples"

for EXAMPLE in $TASKRUNS_EXAMPLES
do
 kubectl create -f "${TEKTON_EXAMPLES_URL}/${EXAMPLE}" -n tutorials || true
done

kubectl port-forward deployment/kibana-kibana 5601 -n ${NAMESPACE}
open http://localhost:5601


