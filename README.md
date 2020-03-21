# kind-cilium-mesh

A [Cilium cluster mesh](https://docs.cilium.io/en/v1.7/gettingstarted/clustermesh/) between two [kind](https://github.com/kubernetes-sigs/kind) clusters for testing purposes.

![License](https://img.shields.io/github/license/bmcstdio/kubectl-topology)

## Prerequisites

* `git`
* [`kind`](https://kind.sigs.k8s.io/docs/user/quick-start/)
* [`kubectl`](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

## Introduction

This project bootstraps a [cluster mesh](https://docs.cilium.io/en/v1.7/gettingstarted/clustermesh/) between two [kind](https://github.com/kubernetes-sigs/kind) clusters using [Cilium](https://cilium.io) which can be used for demo or testing purposes.

## Bootstrapping

To bootstrap the cluster mesh, run

```shell
$ ./kind-cilium-mesh-up.sh
```

This will...

* ... create two kind clusters with one control-plane node and two worker nodes;
* ... install Cilium as the CNI plugin;
* ... expose each cluster's Cilium-managed etcd cluster using a service of type `NodePort`;
* ... configure the cluster mesh using https://github.com/cilium/clustermesh-tools.
* ... deploy an example HTTP application and configure it to be [load-balanced across both clusters](https://docs.cilium.io/en/v1.7/gettingstarted/clustermesh/#load-balancing-with-global-services).

It may take some time for the cluster mesh to be fully operational.
To inspect the status of Cilium and the cluster mesh during or after the process, you may run

```shell
$ for context in kind-kind-cilium-mesh-1 kind-kind-cilium-mesh-2; do                                                                                      
    for pod in $(kubectl --context ${context} -n kube-system get pod -l k8s-app=cilium -o jsonpath='{.items[*].metadata.name}'); do
      kubectl --context ${context} -n kube-system exec ${pod} -- cilium status;
    done
  done
```

When the cluster mesh is fully operational, you should see six of these lines in the output of the above command:

```
Cluster health:   6/6 reachable   (2020-03-21T10:54:51Z)
```

## Testing

To test the cluster mesh and cross-cluster load-balancing, you can run the following command:

```shell
$ kubectl run -i --image giantswarm/tiny-tools --restart Never --rm -t tiny-tools -- /bin/sh -c 'for i in $(seq 1 10); do curl http://cluster-info/; done'
Hello from 'kind-cilium-mesh-1/cluster-info-578986d664-j6lw8'
Hello from 'kind-cilium-mesh-2/cluster-info-5688f75d47-s7fql'
Hello from 'kind-cilium-mesh-1/cluster-info-578986d664-flblg'
Hello from 'kind-cilium-mesh-1/cluster-info-578986d664-j6lw8'
Hello from 'kind-cilium-mesh-2/cluster-info-5688f75d47-s7fql'
Hello from 'kind-cilium-mesh-1/cluster-info-578986d664-j6lw8'
Hello from 'kind-cilium-mesh-2/cluster-info-5688f75d47-7q4cp'
Hello from 'kind-cilium-mesh-2/cluster-info-5688f75d47-7q4cp'
Hello from 'kind-cilium-mesh-1/cluster-info-578986d664-flblg'
Hello from 'kind-cilium-mesh-1/cluster-info-578986d664-j6lw8'
```

You'll be able to observe responses from both clusters (`kind-cilium-mesh-1` and `kind-cilium-mesh-2`) and from two pods from each of these clusters.

## Tearing down

To tear down the kind clusters, run

```shell
$ kind delete cluster --name kind-cilium-mesh-1
$ kind delete cluster --name kind-cilium-mesh-2
```

## License

Copyright 2020 bmcstdio

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
