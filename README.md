# Eways Kubernetes bootstrap (Kubespray)

Documented state: **2026-10-28**. This repository records the configuration and commands used for the single-node test cluster `tst-jfrog`. It is **not yet a completed, healthy cluster**.

## Architecture

- Node: `tst-jfrog` (`192.168.1.203`), Ubuntu 26.04.1 LTS
- Kubernetes: `v1.36.4`
- Container runtime: containerd `2.3.5`
- Installer: upstream Kubespray in `/home/abdollahian/kubespray`
- Custom inventory/config: `/home/abdollahian/eways-kubespray-custom`
- Image registry: `repository.eways.co/docker-k8s` (JFrog virtual Docker repo; local deployment repository `docker-local`)
- Network plan: bootstrap without CNI or kube-proxy; install Helm and then Cilium (kube-proxy replacement) plus Hubble.
- This is a **single-node control-plane, worker and etcd test deployment**, not a highly available production topology.

## Current observed state

```text
tst-jfrog  NotReady  control-plane  v1.36.4  192.168.1.203  containerd://2.3.5
kube-apiserver-tst-jfrog            1/1 Running
kube-controller-manager-tst-jfrog   1/1 Running
kube-scheduler-tst-jfrog            1/1 Running
coredns (two replicas)              0/1 Pending
kube-proxy DaemonSet                absent
```

CoreDNS scheduling events report untolerated taints. The node is NotReady and Cilium has **not** been installed yet. Do not claim the cluster is healthy until a CNI is installed and verified.

## Files

- [Kubespray variables](inventory/eways/group_vars/k8s_cluster/k8s-cluster.yml)
- [JFrog download overrides](inventory/eways/group_vars/all/offline.yml)
- [Installation runner](scripts/03-run-cluster.sh)
- [Bootstrap and troubleshooting notes](docs/installation-progress.md)
- [Image inventory and mirror guidance](docs/images.md)

## Installation

Review the documented prerequisites, adapt inventory and SSH key paths to your environment, then run:

```bash
cd /home/abdollahian/eways-kubespray-custom
./scripts/03-run-cluster.sh 2>&1 | tee /root/eways-kubespray-install.log
```

**Security:** Never commit `.env`, JFrog credentials, passwords, tokens, private SSH keys, or kubeconfig/admin.conf. Container images sourced from third-party mirrors must be verified against official digests before production use.
