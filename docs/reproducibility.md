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

## Installed components and release capture (2026-10-28)

Cilium/Hubble and NFS CSI have now been observed running. Traefik chart 42.1.3 lint passes but its install is not confirmed. Use the checked-in guides in `cilium/`, `nfs/`, and `traefik/`. Before treating examples as the exact deployed configuration, export reviewed live values:

```bash
helm get values cilium -n kube-system -a > /tmp/cilium-live-values.yaml
helm get values csi-driver-nfs -n kube-system -a > /tmp/nfs-live-values.yaml
helm list -A
```

Sanitize sensitive values and diff against version-controlled YAML prior to committing. Keep original chart `.tgz`, digest attestations and the inventory of mirrored images in controlled JFrog artifact repositories. Do not commit kubeconfig, credentials or copied runtime secret manifests.
