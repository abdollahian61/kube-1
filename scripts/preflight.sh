#!/usr/bin/env bash
set -euo pipefail
echo "=== Host ==="; hostnamectl
echo "=== Kubernetes tools ==="
for c in ansible-playbook kubeadm kubectl kubelet nerdctl ctr crictl helm; do
  if command -v "$c" >/dev/null; then echo "$c: $(command -v "$c")"; else echo "$c: NOT INSTALLED"; fi
done
echo "=== containerd ==="; systemctl is-active containerd || true
echo "=== Swap ==="; swapon --show
echo "=== Kernel modules ==="; lsmod | grep -E '^(nf_conntrack|br_netfilter|overlay) ' || true
echo "=== sysctls ==="
sysctl net.ipv4.ip_forward net.netfilter.nf_conntrack_max 2>&1 || true
echo "=== Kubernetes ==="
kubectl get nodes -o wide 2>&1 || true
kubectl get pods -A -o wide 2>&1 || true
kubectl get ds -A 2>&1 || true
