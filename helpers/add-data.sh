#!/usr/bin/env bash
set -e

[[ -n $DEBUG ]] && set -o xtrace

readonly GIT_TOPLEVEL=$(git rev-parse --show-toplevel 2> /dev/null)

source "${GIT_TOPLEVEL}/helpers/tekton-utils.sh"

# Execute some PipelineRuns and TaskRuns
run_tekton_examples "${1}" "${2}"



