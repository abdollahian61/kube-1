# Eways NFS server and CSI driver

Test environment: Ubuntu host and single-node Kubernetes on `192.168.1.203`, allowed NFS clients `192.168.1.0/24`, export `/opt/nfs/kubernetes/volumes`. NFSv4.1 over TCP/2049.

## 1. Server (run on 192.168.1.203)
```bash
sudo bash nfs/install-nfs-server.sh
exportfs -v
ss -lnt | grep 2049
df -h /opt
```
All Kubernetes worker nodes require `nfs-common`. Confirm the exported path is on a suitably sized volume. The provided permissive export uses `no_root_squash` and mode 1777, **only for isolated labs**. Restrict client IPs and implement ownership/ACLs and backups for production. Same-host NFS is not highly available.

## 2. Sync CSI images to Eways JFrog
`registry.k8s.io` returned HTTP 403 in the lab. An alternative pull of `m.daocloud.io/registry.k8s.io/sig-storage/nfsplugin:v4.13.6` was observed progressing; this does **not** prove that all tags are present or independently verified.

```bash
nerdctl login repository.eways.co
TARGET=repository.eways.co/docker-local bash nfs/sync-images-nerdctl.sh
nerdctl pull repository.eways.co/docker-local/sig-storage/nfsplugin:v4.13.6
sudo crictl pull repository.eways.co/docker-local/sig-storage/nfsplugin:v4.13.6
```

The repository key `docker-local` is based on existing project documentation; confirm JFrog Docker routing and permissions. If the registry requires credentials for kubelet pulls, configure appropriate imagePullSecrets or node containerd credentials. Verify official digests before production. Mirror images for every platform used by your nodes.

## 3. Install CSI using internally hosted chart and images
The **chart** must also be published into the Eways JFrog Helm or OCI repository if enforcing all-artifacts-internal. The following uses a local chart package sourced from JFrog; replace the path with the verified downloaded package. Do not fetch directly from a public Helm repo.

```bash
helm template csi-driver-nfs ./csi-driver-nfs-4.13.6.tgz -n kube-system -f nfs/nfs-values.yaml | grep 'image:'
helm upgrade --install csi-driver-nfs ./csi-driver-nfs-4.13.6.tgz -n kube-system -f nfs/nfs-values.yaml --wait --timeout 10m
kubectl get csidrivers
kubectl get pods -n kube-system -l app.kubernetes.io/instance=csi-driver-nfs
```

If Helm reports another operation in progress, inspect `helm status`, `helm history` and active Helm processes; do not remove release secrets blindly.

## 4. StorageClass and test
```bash
kubectl apply -f nfs/storageclass.yaml
kubectl apply -f nfs/test-pvc.yaml
kubectl get pvc -w
```
The test pod references BusyBox in JFrog; push that image first or change to an existing *internal* test image:
```bash
kubectl apply -f nfs/test-pod.yaml
kubectl wait --for=condition=Ready pod/nfs-test --timeout=120s
kubectl exec nfs-test -- cat /data/test.txt
```
Check on the server: `find /opt/nfs/kubernetes/volumes -name test.txt`.

A 5Gi NFS PVC request is not a real server-side quota. Retain reclaim policy deliberately preserves data on PVC deletion. PVC Bound is not proof of a successful pod mount.
