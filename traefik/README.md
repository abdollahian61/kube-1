# Traefik ingress, Eways

Pinned Helm chart `42.1.3`, application `v3.7.16`.

**Status 2026-10-28:** public chart successfully pulled; `helm lint` of custom values passed after correcting an invalid old `logs` key to `log` and `accessLog`. Image push and Traefik runtime installation **not yet confirmed**.

Host files:
- `/opt/eways/charts/traefik/traefik-42.1.3.tgz` (chart binary is not committed here)
- `/opt/eways/charts/traefik/traefik-values.yaml` (recreate using this repo's equivalent file)
- `/opt/eways/charts/traefik/values-default.yaml` (upstream reference)

## Internal image mirror

```bash
nerdctl -n k8s.io pull --platform linux/amd64 docker.io/traefik:v3.7.16
nerdctl -n k8s.io tag docker.io/traefik:v3.7.16 repository.eways.co/docker-k8s/traefik:v3.7.16
nerdctl -n k8s.io push repository.eways.co/docker-k8s/traefik:v3.7.16
```

Ensure JFrog pull works on the Kubernetes node (a local tag alone does not prove the remote push).

## Validate and deploy

```bash
cd /opt/eways/charts/traefik
helm lint ./traefik-42.1.3.tgz -f traefik-values.yaml
helm template traefik ./traefik-42.1.3.tgz -n traefik -f traefik-values.yaml > rendered-eways.yaml
grep -E '^[[:space:]]*image:' rendered-eways.yaml | sort -u
grep -E 'type: NodePort|nodePort:' rendered-eways.yaml

helm upgrade --install traefik ./traefik-42.1.3.tgz \
  --namespace traefik --create-namespace -f traefik-values.yaml \
  --wait --timeout 10m
kubectl get pods,svc -n traefik -o wide
kubectl get ingressclass
helm status traefik -n traefik
```

Expected service: HTTP NodePort 30080, HTTPS NodePort 30443, dashboard **not** publicly exposed. A 404 at nodeIP:NodePort before defining an Ingress is normal; it indicates no matching route, not necessarily a deployment failure. For real HTTPS applications configure valid certificates and DNS/Ingress separately.
