#!/usr/bin/env bash
set -e

[[ -n $DEBUG ]] && set -o xtrace

readonly GIT_TOPLEVEL=$(git rev-parse --show-toplevel 2> /dev/null)

# Donwload the Elastic Docker images used in the cluster
TAG=7.1.1
docker pull docker.elastic.co/elasticsearch/elasticsearch:${TAG}
docker pull docker.elastic.co/kibana/kibana:${TAG}
docker pull docker.elastic.co/beats/filebeat:${TAG}
docker pull docker.elastic.co/beats/metricbeat:${TAG}

# Create the namespace where the pods will be deployed
kubectl create namespace elastic-stack
kubectl create namespace tutorials
kubectl apply -f "${GIT_TOPLEVEL}/pipeline-elastic/config"



