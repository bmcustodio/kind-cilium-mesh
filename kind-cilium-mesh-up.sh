#!/bin/bash

set -euo pipefail

KUBE_SYSTEM_NAMESPACE="kube-system"

CILIUM_NAMESPACE="${KUBE_SYSTEM_NAMESPACE}"
CILIUM_VERSION="v1.11.0-rc3"
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
cilium install --cluster-name "${CLUSTER_1_NAME}" --cluster-id "${CLUSTER_1_NAME/${CLUSTER_NAME_PREFIX}/}" --ipam kubernetes --version "${CILIUM_VERSION}"
kubectl config use "${CLUSTER_2_CONTEXT}"
cilium install --cluster-name "${CLUSTER_2_NAME}" --cluster-id "${CLUSTER_2_NAME/${CLUSTER_NAME_PREFIX}/}" --ipam kubernetes --version "${CILIUM_VERSION}" --inherit-ca "${CLUSTER_1_CONTEXT}"

info "Creating the cluster mesh..."
cilium clustermesh enable --context "${CLUSTER_1_CONTEXT}" --service-type NodePort
cilium clustermesh enable --context "${CLUSTER_2_CONTEXT}" --service-type NodePort
cilium clustermesh status --context "${CLUSTER_1_CONTEXT}" --wait
cilium clustermesh status --context "${CLUSTER_2_CONTEXT}" --wait
cilium clustermesh connect --context "${CLUSTER_1_CONTEXT}" --destination-context "${CLUSTER_2_CONTEXT}"
cilium clustermesh status --context "${CLUSTER_1_CONTEXT}" --wait
cilium clustermesh status --context "${CLUSTER_2_CONTEXT}" --wait

info "Deploying the test application..."
kubectl config use "${CLUSTER_1_CONTEXT}"
kubectl apply -f "${ROOT}/common/rebel-base.yaml" -f "https://raw.githubusercontent.com/cilium/cilium/${CILIUM_VERSION}/examples/kubernetes/clustermesh/global-service-example/cluster1.yaml"
kubectl config use "${CLUSTER_2_CONTEXT}"
kubectl apply -f "${ROOT}/common/rebel-base.yaml" -f "https://raw.githubusercontent.com/cilium/cilium/${CILIUM_VERSION}/examples/kubernetes/clustermesh/global-service-example/cluster2.yaml"

popd > /dev/null
