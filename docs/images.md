# Kubernetes image registry notes

JFrog Docker virtual registry: `repository.eways.co/docker-k8s`, deploying to `docker-local`.

| Destination path | Tag | Observed locally on tst-jfrog |
|---|---|---|
| kube-apiserver | v1.36.4 | yes |
| kube-controller-manager | v1.36.4 | yes |
| kube-scheduler | v1.36.4 | yes |
| coredns/coredns | v1.14.2 | yes |
| pause | 3.10.2 | yes |
| kube-proxy | v1.36.4 | download attempted by Kubespray; mirror operation reported in troubleshooting |
| quay.io/coreos/etcd | v3.6.14 | version determined from Kubespray default checksums; binary-vs-container install must be checked |

The first three images were pulled from the **unofficial third-party Docker Hub mirror** `docker.io/dyrnq` due to `403` from `registry.k8s.io`. Their **official image digests were not verified** in the chat record. Do not treat successful pull/tag/push as supply-chain verification.

Local `nerdctl images` listing only proves images exist on that machine, not that their registry push succeeded. Verify from another environment or use manifest inspection and registry pull tests before relying on JFrog.

```bash
nerdctl -n k8s.io pull repository.eways.co/docker-k8s/kube-apiserver:v1.36.4
nerdctl -n k8s.io pull repository.eways.co/docker-k8s/kube-controller-manager:v1.36.4
nerdctl -n k8s.io pull repository.eways.co/docker-k8s/kube-scheduler:v1.36.4
```

The exact etcd version is selected via `etcd_supported_versions` and `etcd_binary_checksums`; in the inspected Kubespray version `3.6.14` is first for the `1.36` series. Kubespray may download an etcd binary rather than its container image.

Cilium/Hubble image versions are **not** determined yet.
