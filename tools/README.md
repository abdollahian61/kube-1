# Reusable Eways tooling

This directory documents the tools required for repeatable Eways Kubernetes installations. **The binaries themselves are NOT archived here yet.** Never assume GitHub contains a complete offline tool bundle.

| Tool | Purpose | Current known state |
|---|---|---|
| Kubespray | Kubernetes provisioning | Upstream checkout on tst-jfrog |
| Ansible + Python virtualenv | Run Kubespray | Existing venv in custom project |
| containerd | OCI runtime | 2.3.5 on tst-jfrog |
| nerdctl | Pull, tag and push OCI images | Installed |
| ctr | Containerd troubleshooting | Installed |
| crictl | CRI troubleshooting | Installed |
| kubeadm/kubelet/kubectl | Kubernetes bootstrap/operations | v1.36.4 |
| Helm | Install Cilium and future charts | Not yet confirmed installed |
| Cilium CLI | Network validation | Not yet installed |
| Git | Version control | Installed |

For reproducibility, record each binary's version, architecture, SHA-256 and artifact URL, and store the binary in a dedicated **JFrog generic repository**, not as a large binary in Git. Keep this GitHub repository as the source of manifests, checksums, automation and instructions.

Run `scripts/archive-tool-inventory.sh` on the source machine to produce a text inventory. Run `scripts/archive-local-tools.sh` to make a local tarball of selected existing tool binaries, with checksums. Review the archive before uploading to a private artifact store.

The archive scripts **do not automatically upload** to JFrog or GitHub, do not collect credentials, and do not bundle entire containerd or Kubespray installations. An offline project also needs approved binary artifacts, OS packages, Python wheels, Helm charts and container images stored separately.
