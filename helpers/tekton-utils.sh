#!/usr/bin/env bash
set -e

[[ -n $DEBUG ]] && set -o xtrace

# Execute some PipelineRuns and TaskRuns from the official repo
function run_tekton_examples {
    TEKTON_PIPELINE_VERSION="${1}"
    NAMESPACE="${2}"
    TASKRUNS_EXAMPLES="taskruns/build-gcs-targz.yaml taskruns/gcs-resource.yaml taskruns/pullrequest.yaml taskruns/task-multiple-output-image.yaml taskruns/build-gcs-zip.yaml taskruns/git-resource.yaml taskruns/secret-env.yaml taskruns/task-output-image.yaml 
                      taskruns/build-push-kaniko.yaml taskruns/git-ssh-creds.yaml taskruns/secret-volume-params.yaml taskruns/task-volume-args.yaml taskruns/git-volume.yaml taskruns/secret-volume.yaml taskruns/template-volume.yaml  taskruns/home-is-set.yaml 
                      taskruns/sidecar-interp.yaml taskruns/unnamed-steps.yaml taskruns/configmap.yaml taskruns/home-volume.yaml taskruns/sidecar-ready.yaml taskruns/steps-run-in-order.yaml taskruns/workspace.yaml taskruns/docker-creds.yaml 
                      taskruns/steptemplate-env-merge.yaml pipelineruns/output-pipelinerun.yaml pipelineruns/conditional-pipelinerun.yaml"
    TEKTON_EXAMPLES_URL="https://raw.githubusercontent.com/tektoncd/pipeline/v${TEKTON_PIPELINE_VERSION}/examples/v1beta1"

    for EXAMPLE in $TASKRUNS_EXAMPLES
    do
        kubectl create -f "${TEKTON_EXAMPLES_URL}/${EXAMPLE}" -n "${NAMESPACE}" || true
    done
}

