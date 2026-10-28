# OS preparation and official image mirroring

## OS preparation

`scripts/01-prepare-ubuntu.sh` configures Linux kernel modules, IP forwarding, bridge netfilter and optional swap disabling. It deliberately **does not install/replace containerd** (the current host uses standalone containerd 2.3.5), does not alter SSH, DNS, routing, firewall, or CNI, and does not reboot.

```bash
sudo bash scripts/01-prepare-ubuntu.sh
# Optional dependencies, only if your APT mirrors work:
sudo INSTALL_PACKAGES=true bash scripts/01-prepare-ubuntu.sh
```

Default `DISABLE_SWAP=true` runs `swapoff -a` and comments swap entries in `/etc/fstab` after creating a backup. Inspect changes before using this on an existing production machine.

## Mirror directly from official registries

`scripts/mirror-official-images.sh` reads `images-official.txt` and copies original registry images into JFrog via nerdctl. It does not silently substitute a third-party mirror.

```bash
cp .env.example .env
# Set REGISTRY and REPOSITORY, then authenticate interactively.
chmod +x scripts/mirror-official-images.sh
DRY_RUN=true bash scripts/mirror-official-images.sh
bash scripts/mirror-official-images.sh
```

The `.env` file is gitignored. For production, supply independently verified official digests in the third column and set `REQUIRE_DIGEST=true`. The script then pulls by digest rather than trusting a mutable tag. An empty digest does not establish provenance.

**Known constraint:** `registry.k8s.io` returned HTTP 403 from `tst-jfrog` through the existing proxy. This script **cannot bypass** that network restriction. Run it on a host or CI runner with access to the original registry and outbound access to JFrog. On the restricted host, the script will report pull failures.

Images already obtained from an unofficial mirror must be compared with independently obtained official digests before production use. The script verifies that the target can be pulled but a same-host pull can reuse cached layers; use a separate host or registry manifest check for independent verification.

The image list includes kube-proxy because Kubespray downloaded it despite the planned removal. Mirroring the image does not enable kube-proxy.

## Configuration scope

`images-official.txt` covers the confirmed core Kubernetes images. The full inventory for Cilium, Hubble and optional add-ons depends on the exact Helm chart and Kubespray inventory, so do not assume it is complete.
