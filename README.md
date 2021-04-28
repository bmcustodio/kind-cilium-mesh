# kind-cilium-mesh

A [Cilium cluster mesh](https://docs.cilium.io/en/v1.9/gettingstarted/clustermesh/) between two [kind](https://github.com/kubernetes-sigs/kind) clusters for testing purposes.

![License](https://img.shields.io/github/license/bmcustodio/kubectl-topology)

## Prerequisites

* The [`cilium` CLI](https://github.com/cilium/cilium-cli/)
* [`git`](https://git-scm.com/)
* [`jq`](https://stedolan.github.io/jq/download/)
* [`kind`](https://kind.sigs.k8s.io/docs/user/quick-start/)
* [`kubectl`](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

## Introduction

This project bootstraps a [cluster mesh](https://docs.cilium.io/en/stable/gettingstarted/clustermesh/) between two [kind](https://github.com/kubernetes-sigs/kind) clusters using [Cilium](https://cilium.io) which can be used for demo or testing purposes.

## Bootstrapping

To bootstrap the cluster mesh, run

```shell
$ ./kind-cilium-mesh-up.sh
```

This will...

* ... create two kind clusters with one control-plane node and two worker nodes each;
* ... install Cilium in each cluster;
* ... establish a cluster mesh between the two clusters using a service of type `NodePort`;
* ... deploy an example HTTP application and configure it to be [load-balanced across both clusters](https://docs.cilium.io/en/stable/gettingstarted/clustermesh/#load-balancing-with-global-services).

It may take some time for the cluster mesh to be fully operational, but the Cilium CLI will keep you posted during the whole process.

## Testing

To test the cluster mesh and cross-cluster load-balancing, you can run the following command:

```shell
$ kubectl run --restart Never --rm -it --image giantswarm/tiny-tools tiny-tools -- /bin/sh -c 'for i in $(seq 1 10); do curl http://rebel-base/; done'
{"Galaxy": "Alderaan", "Cluster": "Cluster-2"}
{"Galaxy": "Alderaan", "Cluster": "Cluster-1"}
{"Galaxy": "Alderaan", "Cluster": "Cluster-2"}
{"Galaxy": "Alderaan", "Cluster": "Cluster-2"}
{"Galaxy": "Alderaan", "Cluster": "Cluster-2"}
{"Galaxy": "Alderaan", "Cluster": "Cluster-1"}
{"Galaxy": "Alderaan", "Cluster": "Cluster-2"}
{"Galaxy": "Alderaan", "Cluster": "Cluster-1"}
{"Galaxy": "Alderaan", "Cluster": "Cluster-2"}
{"Galaxy": "Alderaan", "Cluster": "Cluster-2"}
pod "tiny-tools" deleted
```

You'll be able to observe responses from both clusters (`Cluster-1` / `kind-cilium-mesh-1` and `Cluster-2` / `kind-cilium-mesh-2`).

## Tearing down

To tear down the kind clusters, run

```shell
$ kind delete cluster --name kind-cilium-mesh-1
$ kind delete cluster --name kind-cilium-mesh-2
```

## License

Copyright 2021 bmcustodio

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
