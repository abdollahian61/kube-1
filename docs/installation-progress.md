# Eways Kubernetes installation progress (2026-10-28)

## Proven configuration
- Single-node `tst-jfrog`, `192.168.1.203`, Ubuntu 26.04.1 LTS
- Kubernetes `1.36.4` via Kubespray; containerd `2.3.5`
- Intentionally installed without another CNI or kube-proxy
- Cilium `1.20.4` via Helm with kube-proxy replacement
- Pod CIDR `10.233.64.0/18`; Service CIDR `10.233.0.0/18`
- JFrog Docker registry `repository.eways.co/docker-k8s`

## Observed Running
- `cilium`, `cilium-envoy`, `cilium-operator`
- `hubble-relay` and two-container `hubble-ui`; UI NodePort `31235`
- 2/2 CoreDNS pods
- API server, controller manager and scheduler
- `csi-nfs-controller` 5/5; `csi-nfs-node` 3/3

## Verified NFS CSI state
- Helm `csi-driver-nfs` deployed revision 2, 2026-10-28
- `CSIDriver nfs.csi.k8s.io` registered
- `eways-nfs` StorageClass, Retain/Immediate
- `default/nfs-test-pvc`: Bound, 5Gi, RWX
- Remaining: test write/read from a mounted Pod

## Traefik status
- Chart `42.1.3` downloaded on `tst-jfrog`; image `docker.io/traefik:v3.7.16`
- `traefik-values.yaml` corrected from unsupported `logs` to `log` and `accessLog`
- `helm lint` succeeded: `1 chart(s) linted, 0 chart(s) failed`
- Image push to JFrog, final `helm template` result and installed release **not evidenced yet**.

## Historical bootstrap troubleshooting
1. Kubespray pin `1.36.5` lacked checksum; fixed to `1.36.4`.
2. `registry.k8s.io` gave HTTP 403; mirrored Kubernetes images to JFrog.
3. Kubespray downloaded kube-proxy image even though kube-proxy was disabled; no kube-proxy DaemonSet should run.
4. `nf_conntrack_max` sysctl initially missing; `modprobe nf_conntrack` corrected this.

## Validation still required

```bash
kubectl get nodes -o wide
kubectl get --raw=/readyz
kubectl get pods -A -o wide
helm list -A
kubectl get ds -n kube-system
kubectl get pvc -A
```

Single-node architecture and same-node NFS server remain single points of failure, unsuitable for an HA production designation.
