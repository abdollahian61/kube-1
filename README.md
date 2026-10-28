# Eways Kubernetes platform

Last reconciled with reported cluster output: **2026-10-28**.

## Cluster inventory
- Lab node: `tst-jfrog`, `192.168.1.203`, Ubuntu 26.04.1
- Kubernetes: **v1.36.4**, installed with Kubespray
- Runtime: **containerd 2.3.5**; Helm is installed
- Bootstrapped without kube-proxy and without another CNI
- Pod CIDR: `10.233.64.0/18`; Service CIDR: `10.233.0.0/18`
- Internal registry: `repository.eways.co/docker-k8s` (JFrog)
- Single-node lab: **not high availability or production ready**

## Observed deployment state

| Component | Pin / details | Evidence |
|---|---|---|
| Kubernetes control plane | v1.36.4 | API/controller/scheduler Running |
| Cilium | Chart 1.20.4; Cilium v1.20.4; kube-proxy replacement | agent, operator, Envoy Running |
| Hubble | Relay/UI enabled; UI NodePort `31235` | Relay 1/1 and UI 2/2 Running |
| CoreDNS | two replicas | both Running |
| NFS CSI | Chart 4.13.6 | Helm deployed revision 2; controller 5/5, node 3/3 |
| NFS StorageClass | `eways-nfs`, RWX, Retain | test PVC 5Gi Bound |
| Traefik | Chart 42.1.3; app v3.7.16 | Chart downloaded and values linted; **installation not yet confirmed** |

**Validation outstanding:** latest `kubectl get nodes` Ready status, end-to-end Cilium connectivity, NFS read/write from a pod, and Traefik actual Deployment/Service. Do not confuse a Running Pod or Bound PVC with these tests.

## Directories

- [Kubespray inventory and settings](inventory/eways/)
- [Cilium chart values and setup](cilium/)
- [Traefik chart values and setup](traefik/)
- [NFS server, CSI, StorageClass and test](nfs/)
- [Current installation status](docs/installation-progress.md)
- [NFS CSI live evidence](docs/nfs-csi-installation.md)
- [Reproducible build checklist](docs/reproducibility.md)

## Validation

```bash
kubectl get nodes -o wide
kubectl get pods -A -o wide
kubectl get csidrivers,storageclasses
kubectl get pvc -A
helm list -A
kubectl get svc -n kube-system hubble-ui
```

## Security

Never commit credentials, kubeconfig, SSH keys, JFrog tokens or locally rendered manifests containing sensitive values. This repo stores source configuration and runbooks, **not** private cluster snapshots or vendor chart packages.
