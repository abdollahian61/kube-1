#!/usr/bin/env bash
set -euo pipefail
[[ "$EUID" -eq 0 ]] || { echo "Run as root" >&2; exit 1; }
cat > /etc/modules-load.d/eways-kubernetes.conf <<'EOF'
nf_conntrack
br_netfilter
overlay
EOF
for module in nf_conntrack br_netfilter overlay; do modprobe "$module"; done
sysctl net.netfilter.nf_conntrack_max
