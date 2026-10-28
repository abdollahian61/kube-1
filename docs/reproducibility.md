# Repeatable installation checklist

The GitHub repository contains installation scripts and known settings. It does **not** yet contain a complete reproducible offline snapshot of the running host.

For each future Eways project:

1. Pin upstream Kubespray to an exact commit and archive a reviewed source snapshot in an internal artifact repository.
2. Pin Python/Ansible requirements and store a compatible wheelhouse.
3. Archive approved binaries with SHA256: containerd, nerdctl, crictl, kubeadm, kubelet, kubectl, Helm and (when installed) Cilium CLI.
4. Archive Kubernetes, Cilium and Hubble images into JFrog, preserving manifest digests and architecture.
5. Archive the chosen Helm chart packages and their checksums.
6. Record Ubuntu release, architecture, kernel, OS package versions and repository mirrors. An OS preparation script is not an offline OS package mirror.
7. Maintain separate environment inventories and secrets outside the public GitHub repository.
8. Test the full process on a clean VM without depending on the source host's cached images.

To inventory tools:
```bash
cd /path/to/kube-1
bash scripts/archive-tool-inventory.sh
bash scripts/archive-local-tools.sh
```

Upload the resulting tarball and inventory to your private JFrog generic repository after reviewing their contents. The scripts do not automatically push the artifacts.
