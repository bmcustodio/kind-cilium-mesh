#!/bin/bash

set -euo pipefail

CILIUM_VERSION="v1.10.0-rc0"
CLUSTER_NAME_PREFIX="kind-cilium-mesh-"
CLUSTER_1_NAME="${CLUSTER_NAME_PREFIX}1"
CLUSTER_1_CONTEXT="kind-${CLUSTER_1_NAME}"

ROOT="$(git rev-parse --show-toplevel)"

pushd "${ROOT}" > /dev/null

kind create cluster --name "${CLUSTER_1_NAME}" --config kind.yaml
kubectl config use "${CLUSTER_1_CONTEXT}"
cilium install --cluster-name "${CLUSTER_1_NAME}" --cluster-id "${CLUSTER_1_NAME/${CLUSTER_NAME_PREFIX}/}" --ipam kubernetes --version "${CILIUM_VERSION}"
cilium clustermesh enable --context "${CLUSTER_1_CONTEXT}" --service-type NodePort

popd > /dev/null
