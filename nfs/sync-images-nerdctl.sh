#!/usr/bin/env bash
set -Eeuo pipefail
# Set TARGET to the verified writable Docker endpoint in JFrog.
SOURCE="${SOURCE:-m.daocloud.io/registry.k8s.io}"
TARGET="${TARGET:-repository.eways.co/docker-local}"
IMAGES=(
 nfsplugin:v4.13.6
 csi-provisioner:v6.3.0
 csi-resizer:v2.2.1
 csi-snapshotter:v8.6.0
 livenessprobe:v2.19.0
 csi-node-driver-registrar:v2.17.0
)
command -v nerdctl >/dev/null || { echo "nerdctl not found" >&2; exit 1; }
for img in "${IMAGES[@]}"; do
  src="${SOURCE}/sig-storage/${img}"
  dst="${TARGET}/sig-storage/${img}"
  echo "Pull $src"
  nerdctl pull "$src"
  nerdctl tag "$src" "$dst"
  nerdctl push "$dst"
done
echo "Verify JFrog pull from containerd before deploying. Validate image digests for production."
