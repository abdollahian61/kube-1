# Eways Kubernetes: installation progress

## Provisioned

- Single node `tst-jfrog` at `192.168.1.203`, Ubuntu 26.04.1 LTS, Linux kernel `7.0.0-38-generic`.
- Standalone containerd `2.3.5` with nerdctl and Kubernetes binaries.
- Kubespray uses custom settings in this repo with upstream `cluster.yml`.
- Desired topology: **no CNI during Kubespray bootstrap**, **no kube-proxy**, Cilium to be installed later with Helm.

## Resolved installation problems

1. `kube_version: 1.36.5` had no matching checksum in the checked-out Kubespray set; changed to `1.36.4`.
2. Direct image pulls from `registry.k8s.io` through the configured proxy hit HTTP `403` for `kube-apiserver`. Required images were mirrored into JFrog.
3. Kubespray attempted to download `kube-proxy:v1.36.4` even with `kube_proxy_remove: true`; the image was mirrored to allow the download task. This does not mean kube-proxy should run.
4. The sysctl reload initially failed because `/proc/sys/net/netfilter/nf_conntrack_max` was absent. Loading `nf_conntrack` fixed it; `sysctl net.netfilter.nf_conntrack_max` then returned `262144`. Persist modules using the file below.

```bash
sudo tee /etc/modules-load.d/eways-kubernetes.conf >/dev/null <<'EOF'
nf_conntrack
br_netfilter
overlay
EOF
sudo modprobe nf_conntrack br_netfilter overlay
sudo sysctl --system
```

## Observed state on 2026-10-28

```bash
kubectl get nodes -o wide
kubectl get pods -A -o wide
kubectl get ds -n kube-system
```

Observed: the API server, controller manager, and scheduler are Running; node is `NotReady`; both CoreDNS replicas are `Pending`; no DaemonSets exist in kube-system. A CoreDNS scheduling event says `node(s) had untolerated taint(s)`. **Do not remove taints blindly.** Check current taints, node conditions, and Pending events after Cilium is installed.

## Next steps (NOT completed)

1. Confirm Helm availability and Kubernetes API readiness:
   ```bash
   helm version
   kubectl get --raw=/readyz
   kubectl describe node tst-jfrog | grep -A5 Taints
   kubectl get endpoints kubernetes -o wide
   ```
2. Select a supported Cilium chart version and verify it against Kubernetes `1.36` and kernel `7.0`.
3. Mirror/chart-verify required Cilium, operator, Hubble and Envoy images into JFrog.
4. Install Cilium via Helm with kube-proxy replacement. For kube-proxy-free bootstrap, explicitly provide `k8sServiceHost=192.168.1.203`, `k8sServicePort=6443` and verify actual API reachability. Decide on Hubble Relay/UI values from the selected chart; do not assume version-specific settings.
5. Validate `kubectl get nodes`, `kubectl get pods -A`, CoreDNS DNS resolution, Cilium health and absence of kube-proxy.

No production readiness or successful Cilium installation is asserted here.
