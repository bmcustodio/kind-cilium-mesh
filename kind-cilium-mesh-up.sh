#!/bin/bash

set -euxo pipefail

CILIUM_CLUSTERMESH_TOOLS_DIR="clustermesh-tools"
CILIUM_NAMESPACE="kube-system"
CLUSTER_1_NAME="kind-cilium-mesh-1"
CLUSTER_2_NAME="kind-cilium-mesh-2"

ROOT="$(git rev-parse --show-toplevel)"

function info() {
    echo "=> ${1}"
}

pushd "${ROOT}" > /dev/null

info "Cloning 'cilium/clustermesh-tools..."
if [[ ! -d "${CILIUM_CLUSTERMESH_TOOLS_DIR}" ]];
then
    git clone https://github.com/cilium/clustermesh-tools.git "${CILIUM_CLUSTERMESH_TOOLS_DIR}"
fi

for cluster in ${CLUSTER_1_NAME} ${CLUSTER_2_NAME};
do
    info "Creating '${cluster}'..."
    kind create cluster --name "${cluster}" --config "${cluster}/kind.yaml"
    kubectl config use "kind-${cluster}"
    info "Installing Cilium...."
    kubectl apply -f "${cluster}/cilium.yaml"
    info "Waiting for Cilium to be ready..."
    kubectl -n "${CILIUM_NAMESPACE}" wait --for condition=Ready pod --selector k8s-app=cilium --timeout 5m
    kubectl -n "${CILIUM_NAMESPACE}" wait --for condition=Ready pod --selector io.cilium/app=etcd-operator --timeout 5m
    info "Waiting for the Cilium-managed 'etcd' cluster to be ready..."
    kubectl -n "${CILIUM_NAMESPACE}" wait --for condition=Available etcdcluster cilium-etcd --timeout 5m
    info "Exposing the Cilium-managed 'etcd' cluster via a 'NodePort' service..."
    kubectl apply -f "${cluster}/cilium-etcd-external.yaml"
    info "Extracting the Cilium-managed 'etcd' cluster's secrets..."
    pushd "${CILIUM_CLUSTERMESH_TOOLS_DIR}" > /dev/null
    CLUSTER_NAME="${cluster}" NAMESPACE="${CILIUM_NAMESPACE}" ./extract-etcd-secrets.sh
    popd > /dev/null
done

pushd "${CILIUM_CLUSTERMESH_TOOLS_DIR}" > /dev/null
info "Generating the cluster mesh secrets..."
./generate-secret-yaml.sh > clustermesh.yaml
./generate-name-mapping.sh > ds.patch

for cluster in ${CLUSTER_1_NAME} ${CLUSTER_2_NAME};
do
    info "Configuring the cluster mesh in '${cluster}'..."
    kubectl config use "kind-${cluster}"
    kubectl -n "${CILIUM_NAMESPACE}" apply -f ./clustermesh.yaml
    kubectl -n "${CILIUM_NAMESPACE}" patch daemonset cilium -p "$(cat ./ds.patch)"
    kubectl -n "${CILIUM_NAMESPACE}" delete pod -l k8s-app=cilium
    kubectl -n "${CILIUM_NAMESPACE}" delete pod -l name=cilium-operator
done

popd > /dev/null

for cluster in ${CLUSTER_1_NAME} ${CLUSTER_2_NAME};
do
    info "Deploying the 'cluster-info' application..."
    kubectl config use "kind-${cluster}"
    kubectl -n "${CILIUM_NAMESPACE}" apply -f "${cluster}/cluster-info.yaml"
done

popd > /dev/null
