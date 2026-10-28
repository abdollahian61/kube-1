#!/usr/bin/env bash
set -Eeuo pipefail
OUT="${1:-tools/tool-inventory.txt}"
mkdir -p "$(dirname "$OUT")"
{
 echo "# Eways tool inventory"
 echo "# generated_utc=$(date -u +%FT%TZ)"
 echo "# os=$(grep '^PRETTY_NAME=' /etc/os-release 2>/dev/null || true)"
 echo "# kernel=$(uname -r) arch=$(uname -m)"
 for tool in python3 ansible ansible-playbook containerd nerdctl ctr crictl kubeadm kubelet kubectl helm cilium git; do
   echo "=== $tool ==="
   if p="$(command -v "$tool" 2>/dev/null)"; then
     echo "path=$p"
     sha256sum "$p" 2>/dev/null || true
     timeout 5 "$tool" --version 2>&1 | head -3 || true
   else echo "NOT_INSTALLED"; fi
 done
} > "$OUT"
echo "Created $OUT"
