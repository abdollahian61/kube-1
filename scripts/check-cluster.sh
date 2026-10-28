#!/usr/bin/env bash
set -euo pipefail
kubectl get --raw=/readyz
kubectl get nodes -o wide
kubectl get pods -A -o wide
kubectl get ds -A
kubectl describe node tst-jfrog | grep -A 8 '^Taints:' || true
kubectl get endpoints kubernetes -o wide
