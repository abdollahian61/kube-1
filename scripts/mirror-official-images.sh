#!/usr/bin/env bash
# Pull Kubernetes images from their ORIGINAL registries, then push to JFrog.
# Requires nerdctl, containerd, an accessible original registry and JFrog credentials.
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${ENV_FILE:-$ROOT/.env}"
LIST="${IMAGE_LIST:-$ROOT/images-official.txt}"
[[ -f "$ENV_FILE" ]] && { set -a; source "$ENV_FILE"; set +a; }
: "${REGISTRY:=repository.eways.co}"
: "${REPOSITORY:=docker-k8s}"
: "${NERDCTL_NAMESPACE:=k8s.io}"
: "${PLATFORM:=linux/amd64}"
: "${DRY_RUN:=false}"
: "${VERIFY_REMOTE:=true}"
: "${REQUIRE_DIGEST:=false}"
command -v nerdctl >/dev/null || { echo "nerdctl is required" >&2; exit 1; }
[[ -f "$LIST" ]] || { echo "Missing image list $LIST" >&2; exit 1; }
N=(nerdctl -n "$NERDCTL_NAMESPACE")
if [[ "$DRY_RUN" != true ]]; then
  if [[ -n "${REGISTRY_USER:-}" && -n "${REGISTRY_PASSWORD:-}" ]]; then
    printf '%s' "$REGISTRY_PASSWORD" | nerdctl login "$REGISTRY" -u "$REGISTRY_USER" --password-stdin
  else
    nerdctl login "$REGISTRY"
  fi
fi
success=0; errors=0
while IFS='|' read -r source target digest || [[ -n "${source:-}" ]]; do
  source="${source%%#*}"
  source="$(echo "$source" | xargs)"
  target="$(echo "${target:-}" | xargs)"
  digest="$(echo "${digest:-}" | xargs)"
  [[ -z "$source" ]] && continue
  [[ -n "$target" && "$target" != /* && "$target" != *..* ]] || { echo "Invalid destination for $source" >&2; errors=$((errors+1)); continue; }
  dest="${REGISTRY%/}/${REPOSITORY#/}/$target"
  echo "==> $source -> $dest"
  if [[ "$REQUIRE_DIGEST" == true && ! "$digest" =~ ^sha256:[a-f0-9]{64}$ ]]; then
    echo "Missing approved digest for $source" >&2; errors=$((errors+1)); continue
  fi
  if [[ "$DRY_RUN" == true ]]; then continue; fi
  # When digest is specified, pull by digest, not by mutable tag.
  pullref="$source"
  if [[ -n "$digest" ]]; then pullref="${source%@*}"; pullref="${pullref%:*}@$digest"; fi
  if ! "${N[@]}" pull --platform "$PLATFORM" "$pullref"; then errors=$((errors+1)); continue; fi
  if ! "${N[@]}" tag "$pullref" "$dest"; then errors=$((errors+1)); continue; fi
  if ! "${N[@]}" push --platform "$PLATFORM" "$dest"; then errors=$((errors+1)); continue; fi
  if [[ "$VERIFY_REMOTE" == true ]] && ! "${N[@]}" pull --platform "$PLATFORM" "$dest"; then errors=$((errors+1)); continue; fi
  success=$((success+1))
done < "$LIST"
echo "Mirrored: $success; failures: $errors"
(( errors == 0 ))
