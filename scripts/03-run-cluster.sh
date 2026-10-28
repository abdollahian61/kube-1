#!/usr/bin/env bash
set -euo pipefail

CUSTOM_DIR="/home/abdollahian/eways-kubespray-custom"
KUBESPRAY_DIR="/home/abdollahian/kubespray"

source "${CUSTOM_DIR}/venv/bin/activate"
cd "${KUBESPRAY_DIR}"

ansible-playbook \
  -i "${CUSTOM_DIR}/inventory/eways/hosts.yaml" \
  --become \
  --become-user=root \
  cluster.yml
