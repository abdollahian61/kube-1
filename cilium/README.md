# Cilium 1.20.4 + Hubble on Eways

Reported installed via Helm on 2026-10-28, running with Kubernetes 1.36.4 on `tst-jfrog`.

- Archive on host: `/opt/eways/charts/cilium/cilium-1.20.4.tgz`
- Overrides on host: `/opt/eways/charts/cilium/cilium-values.yaml`
- API endpoint: `192.168.1.203:6443`
- No kube-proxy. `kubeProxyReplacement: true`
- Hubble UI: `http://192.168.1.203:31235`
- One operator replica.
- Images hosted under `repository.eways.co/docker-k8s/cilium/`.

Known image tags:
```text
cilium:v1.20.4
operator-generic:v1.20.4
cilium-envoy:v1.39.5-1792733054-8c73b2816bc8239e27f1fd53b271884688137459
hubble-relay:v1.20.4
hubble-ui:v0.13.6
hubble-ui-backend:v0.13.6
```

For `operator.image.repository`, the chart appends `-generic` itself. All mirrored image overrides require `useDigest: false` where supported because original upstream digests do not correspond to JFrog image locations.

## Render, verify and install

Use the **reviewed, exact values from the running host**; `values.yaml.example` documents known settings but is not guaranteed a byte-for-byte export of the live release.

```bash
cd /opt/eways/charts/cilium
helm lint cilium-1.20.4.tgz -f cilium-values.yaml
helm template cilium cilium-1.20.4.tgz -n kube-system -f cilium-values.yaml > rendered-cilium.yaml
grep -E '^[[:space:]]*image:' rendered-cilium.yaml | sort -u
helm upgrade --install cilium ./cilium-1.20.4.tgz -n kube-system -f cilium-values.yaml --wait --timeout 10m
```

`helm get values cilium -n kube-system -a` exports effective running values; review before committing. Validate:

```bash
helm status cilium -n kube-system
kubectl get nodes -o wide
kubectl get pods -n kube-system -o wide
kubectl get ds -n kube-system
kubectl get svc hubble-ui -n kube-system
kubectl -n kube-system exec ds/cilium -- cilium-dbg status --verbose
kubectl get ds -n kube-system kube-proxy
```

The last command should report NotFound in the intentional kube-proxy-free architecture.

## Known observations
Cilium agent, Envoy, operator, Relay and UI were all Running. Both CoreDNS pods were Running. These observations do not replace cross-node connectivity or policy tests.
