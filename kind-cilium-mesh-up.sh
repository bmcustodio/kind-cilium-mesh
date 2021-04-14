#!/bin/bash

set -euo pipefail

CLUSTER_NAME_PREFIX="kind-cilium-mesh-"
CLUSTER_1_NAME="${CLUSTER_NAME_PREFIX}1"
CLUSTER_1_CONTEXT="kind-${CLUSTER_1_NAME}"
CLUSTER_2_NAME="${CLUSTER_NAME_PREFIX}2"
CLUSTER_2_CONTEXT="kind-${CLUSTER_2_NAME}"

ROOT="$(git rev-parse --show-toplevel)"

function info() {
    echo "=> ${1}"
}

pushd "${ROOT}" > /dev/null

info "Creating the clusters..."
kind create cluster --name "${CLUSTER_1_NAME}" --config "${CLUSTER_1_NAME}/kind.yaml"
kind create cluster --name "${CLUSTER_2_NAME}" --config "${CLUSTER_2_NAME}/kind.yaml"


info "Installing Cilium...."
kubectl config use "${CLUSTER_1_CONTEXT}"
cilium install --cluster-name "${CLUSTER_1_NAME}" --cluster-id "${CLUSTER_1_NAME/${CLUSTER_NAME_PREFIX}/}" --ipam kubernetes --version v1.10.0-rc0
kubectl config use "${CLUSTER_2_CONTEXT}"
cilium install --cluster-name "${CLUSTER_2_NAME}" --cluster-id "${CLUSTER_2_NAME/${CLUSTER_NAME_PREFIX}/}" --ipam kubernetes --version v1.10.0-rc0 --inherit-ca "${CLUSTER_1_CONTEXT}"

info "Creating the cluster mesh..."
cilium clustermesh enable --context "${CLUSTER_1_CONTEXT}" --service-type NodePort
cilium clustermesh enable --context "${CLUSTER_2_CONTEXT}" --service-type NodePort
cilium clustermesh status --context "${CLUSTER_1_CONTEXT}" --wait
cilium clustermesh status --context "${CLUSTER_2_CONTEXT}" --wait
cilium clustermesh connect --context "${CLUSTER_1_CONTEXT}" --destination-context "${CLUSTER_2_CONTEXT}"
cilium clustermesh status --context "${CLUSTER_1_CONTEXT}" --wait

popd > /dev/null
