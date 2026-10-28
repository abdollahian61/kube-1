#!/usr/bin/env bash
# Archive only approved, existing executable files; never archive keys/configs.
set -Eeuo pipefail
OUT="${1:-$PWD/eways-tools-$(uname -m).tar.gz}"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin"
for tool in containerd nerdctl ctr crictl kubeadm kubelet kubectl helm cilium; do
  p="$(command -v "$tool" 2>/dev/null || true)"
  if [[ -n "$p" && -f "$p" ]]; then
    cp -L "$p" "$tmp/bin/$tool"
  else
    echo "Skipping missing $tool"
  fi
done
( cd "$tmp" && sha256sum bin/* > SHA256SUMS && tar -czf "$OUT" bin SHA256SUMS )
echo "Created: $OUT"
echo "IMPORTANT: This tarball contains executable binaries. Validate their origin and checksums before reuse."
