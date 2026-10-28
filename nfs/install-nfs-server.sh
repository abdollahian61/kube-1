#!/usr/bin/env bash
set -Eeuo pipefail
# Eways NFS server: run as root on 192.168.1.203
NFS_IP="${NFS_IP:-192.168.1.203}"
NFS_NETWORK="${NFS_NETWORK:-192.168.1.0/24}"
NFS_PATH="${NFS_PATH:-/opt/nfs/kubernetes/volumes}"
[[ $EUID -eq 0 ]] || { echo "Run as root" >&2; exit 1; }
. /etc/os-release
[[ "$ID" == ubuntu ]] || { echo "Ubuntu required" >&2; exit 1; }
ip -4 -o addr show | grep -Fq "inet ${NFS_IP}/" || { echo "Server IP not found: $NFS_IP" >&2; exit 1; }
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y nfs-kernel-server nfs-common
install -d -m 755 /etc/exports.d /etc/nfs.conf.d
install -d -m 1777 "$NFS_PATH"
cat > /etc/exports.d/eways.exports <<EOF
$NFS_PATH $NFS_NETWORK(rw,sync,no_subtree_check,no_root_squash)
EOF
cat > /etc/nfs.conf.d/eways.conf <<'EOF'
[nfsd]
vers3=n
vers4=y
vers4.0=n
vers4.1=y
vers4.2=y
EOF
systemctl enable --now nfs-server
systemctl restart nfs-server
exportfs -ra
if command -v ufw >/dev/null && ufw status | grep -q '^Status: active'; then
  ufw allow from "$NFS_NETWORK" to any port 2049 proto tcp
fi
systemctl is-active --quiet nfs-server
exportfs -v
echo "NFS ready at ${NFS_IP}:${NFS_PATH}; allowed clients ${NFS_NETWORK}"
echo "WARNING: no_root_squash and world-writable directory are suitable only for isolated test environments."
