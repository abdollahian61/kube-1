#!/usr/bin/env bash
# Idempotent host preparation for Eways Kubespray (Ubuntu 24.04/26.04).
# Does NOT install Docker, containerd, kubelet, Cilium or change the network stack.
set -Eeuo pipefail
[[ "$EUID" -eq 0 ]] || { echo "Run as root" >&2; exit 1; }
source /etc/os-release
[[ "$ID" == ubuntu ]] || { echo "Ubuntu required" >&2; exit 1; }
: "${DISABLE_SWAP:=true}"
: "${INSTALL_PACKAGES:=false}"
: "${SET_HOSTNAME:=}"
echo "Preparing $PRETTY_NAME for Kubernetes"
if [[ -n "$SET_HOSTNAME" ]]; then hostnamectl set-hostname "$SET_HOSTNAME"; fi
if [[ "$INSTALL_PACKAGES" == true ]]; then
  apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates curl jq chrony conntrack socat iptables iproute2
fi
cat >/etc/modules-load.d/eways-k8s.conf <<'EOF'
overlay
br_netfilter
nf_conntrack
EOF
for module in overlay br_netfilter nf_conntrack; do modprobe "$module"; done
cat >/etc/sysctl.d/99-eways-kubernetes.conf <<'EOF'
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sysctl --system >/dev/null
if [[ "$DISABLE_SWAP" == true ]]; then
  swapoff -a
  if [[ -f /etc/fstab ]]; then
    cp -n /etc/fstab /etc/fstab.eways-pre-k8s.bak
    # Comment only active swap entries, preserving the original line.
    sed -i -E '/^[[:space:]]*#/! { /^[^#]*[[:space:]]swap[[:space:]]/ s|^|# disabled-for-kubernetes: |; }' /etc/fstab
  fi
fi
echo "=== Kernel ==="; uname -r
echo "=== Loaded modules ==="; lsmod | grep -E '^(overlay|br_netfilter|nf_conntrack) ' || true
echo "=== Required sysctls ==="
sysctl net.ipv4.ip_forward net.bridge.bridge-nf-call-iptables net.netfilter.nf_conntrack_max
echo "=== Swap ==="; swapon --show
echo "=== Container runtime (not changed) ==="; systemctl is-active containerd || true
echo "Host preparation complete. Review time sync, firewall and kubeadm preflight separately."
