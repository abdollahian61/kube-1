# Eways Kubernetes platform: outstanding actions

As of 2026-10-28 Cilium/Hubble and NFS CSI are running; these are **no longer installation TODOs**.

1. Validate `kubectl get nodes` Ready and Cilium agent health, pod DNS and networking; save sanitized proof.
2. Confirm actual chart/override parity: `helm get values cilium -n kube-system -a`.
3. Run NFS read/write test from a pod using the bound `eways-nfs` PVC.
4. Mirror Traefik `v3.7.16` to JFrog; inspect final Helm render (NodePorts 30080/30443); install and test.
5. Create/verify a local JFrog Helm repository and publish chart archives with SHA256 (previously `helm-eways-local` was not found).
6. Verify metrics server, TLS/cert-manager, resource limits, network policy, ingress access, and monitoring before application rollout.
7. Store sanitized inventories/configuration in Git; keep secrets separate.
8. Make etcd and NFS backup/restore reproducible, then test disaster recovery.
9. For production, plan multiple control-plane/worker nodes and independent, resilient storage.

Do not mark Traefik or workload data path as complete without runtime evidence.
