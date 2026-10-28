# Next steps: Helm, Cilium, Hubble

**Not installed as of the latest observed cluster output.**

1. Run `scripts/check-cluster.sh` and inspect node taints and API readiness.
2. Install a pinned, verified Helm binary (via approved internal artifact source).
3. Select and pin a Cilium chart version supporting Kubernetes v1.36.4 and the host kernel.
4. Obtain the chart and list **all images from the actual rendered Helm templates**, including Cilium agent, operator, Envoy, Hubble relay and UI.
5. Mirror images to JFrog, verify provenance and digests, and configure the chart to reference internal image paths.
6. Start from `cilium/values.yaml.example`, adjust values for the selected chart and confirm API access at `192.168.1.203:6443`.
7. Install Cilium using Helm only after the above validation. Do not install a second CNI or enable kube-proxy.
8. Verify node Ready, CoreDNS Running, Cilium health and pod-to-pod/service connectivity.

This document intentionally does not provide a blind `helm install` command for an unverified chart/image set.
