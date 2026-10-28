# Eways NFS CSI installation record

Last reviewed: 2026-10-28. Source: earlier Eways NFS CSI deployment conversation and the existing files in `nfs/`.

## Configuration captured

| Setting | Value |
|---|---|
| Kubernetes host / NFS server | `tst-jfrog` / `192.168.1.203` |
| Client network | `192.168.1.0/24` |
| NFS export | `/opt/nfs/kubernetes/volumes` |
| NFS protocol | v4.1, TCP/2049 |
| Helm release | `csi-driver-nfs` |
| Chart | `csi-driver-nfs-4.13.6.tgz` |
| Namespace | `kube-system` |
| StorageClass | `eways-nfs` |
| CSI provisioner | `nfs.csi.k8s.io` |
| Reclaim policy | `Retain` |

## Files already committed

- `nfs/install-nfs-server.sh`: NFS server/export setup
- `nfs/sync-images-nerdctl.sh`: mirror CSI component images to JFrog
- `nfs/nfs-values.yaml`: Helm image overrides and controller settings
- `nfs/storageclass.yaml`: dynamic NFS StorageClass
- `nfs/test-pvc.yaml`, `nfs/test-pod.yaml`: end-to-end storage test
- `nfs/README.md`: setup, limitations, and operational commands

**Registry caveat:** NFS manifests currently use `repository.eways.co/docker-local`, while later Cilium/Traefik work uses `repository.eways.co/docker-k8s`. Confirm which Docker repository actually holds the NFS CSI images before applying or upgrading. Do not silently substitute a registry.

## Validate the actual running installation

Run on `tst-jfrog`:

```bash
helm status csi-driver-nfs -n kube-system
helm get values csi-driver-nfs -n kube-system
kubectl get csidrivers
kubectl get pods -n kube-system -o wide | grep -E 'nfs|NAME'
kubectl get storageclass eways-nfs -o yaml
kubectl get pvc -A
sudo exportfs -v
sudo ss -lnt | grep ':2049'
```

For a functional test, after confirming the test Pod image is accessible in the internal registry:

```bash
kubectl apply -f nfs/test-pvc.yaml
kubectl apply -f nfs/test-pod.yaml
kubectl wait --for=condition=Ready pod/nfs-test --timeout=120s
kubectl exec nfs-test -- cat /data/test.txt
```

Verify the file exists on the NFS server under the exported path.

## Installation status

**Observed 2026-10-28:** Helm release `csi-driver-nfs` is `deployed` (revision 2); controller Pod `5/5 Running`; node Pod `3/3 Running`; `CSIDriver nfs.csi.k8s.io` registered; `StorageClass eways-nfs` exists (`Retain`, `Immediate`); PVC `default/nfs-test-pvc` is `Bound` with `5Gi`, `RWX`, volume `pvc-f6eaf4ac-a436-40bc-aa24-2dbba6a85097`. **Driver installation and dynamic provisioning are verified. End-to-end pod mount and read/write remain unverified** pending `kubectl exec` test.

## Operational considerations

- Single-host NFS is a single point of failure; do not call it highly available.
- `Retain` preserves PV data but is not a backup.
- A PVC size request does not enforce a real filesystem quota on a shared NFS export.
- The permissive lab export (`no_root_squash`) should be replaced with scoped access/ownership and backups for production.
