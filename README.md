# kind-cilium-mesh

![License](https://img.shields.io/github/license/bmcustodio/kind-cilium-mesh)

## Prerequisites

* [`cilium-cli`](https://github.com/cilium/cilium-cli)
* [`git`](https://git-scm.com/)
* [`kind`](https://kind.sigs.k8s.io/docs/user/quick-start/)
* [`kubectl`](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

## Running

```
$ make
$ kubectl -n kube-system logs -l k8s-app=clustermesh-apiserver -c apiserver
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
