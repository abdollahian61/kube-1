#!/usr/bin/env bash
# Mirror explicitly listed OCI images into an internal registry using nerdctl.
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${ENV_FILE:-$ROOT/.env}"
IMAGE_LIST="${IMAGE_LIST:-$ROOT/images.txt}"
[[ -f "$ENV_FILE" ]] && { set -a; source "$ENV_FILE"; set +a; }
: "${REGISTRY:?Set REGISTRY in .env}"
: "${REPOSITORY:?Set REPOSITORY in .env}"
: "${PLATFORM:=linux/amd64}"
: "${NERDCTL_NAMESPACE:=k8s.io}"
: "${VERIFY_REMOTE:=true}"
: "${REQUIRE_DIGEST:=true}"
[[ -f "$IMAGE_LIST" ]] || { echo "Missing image list: $IMAGE_LIST" >&2; exit 1; }
command -v nerdctl >/dev/null || { echo "nerdctl not installed" >&2; exit 1; }
N=(nerdctl -n "$NERDCTL_NAMESPACE")
if [[ -n "${REGISTRY_USER:-}" && -n "${REGISTRY_PASSWORD:-}" ]]; then
  printf '%s' "$REGISTRY_PASSWORD" | nerdctl login "$REGISTRY" -u "$REGISTRY_USER" --password-stdin
else
  echo "Interactive login to $REGISTRY"
  nerdctl login "$REGISTRY"
fi
ok=0; failed=0
while IFS='|' read -r source destination expected_digest || [[ -n "${source:-}" ]]; do
  source="${source%%#*}"
  source="$(echo "$source" | xargs)"
  destination="$(echo "${destination:-}" | xargs)"
  expected_digest="$(echo "${expected_digest:-}" | xargs)"
  [[ -z "$source" ]] && continue
  if [[ -z "$destination" ]]; then echo "Missing destination for $source" >&2; failed=$((failed+1)); continue; fi
  if [[ "$REQUIRE_DIGEST" == true && ! "$expected_digest" =~ ^sha256:[a-f0-9]{64}$ ]]; then
    echo "REFUSED: $source has no independently verified sha256 digest" >&2
    failed=$((failed+1)); continue
  fi
  target="${REGISTRY%/}/${REPOSITORY#/}/$destination"
  echo "Mirroring $source -> $target"
  if ! "${N[@]}" pull --platform "$PLATFORM" "$source"; then failed=$((failed+1)); continue; fi
  # A tag's locally printed image ID is NOT the registry manifest digest.
  # Inspect registry manifest digest; require exact match when provided.
  if [[ -n "$expected_digest" ]]; then
    actual="$(nerdctl manifest inspect "$source" --verbose 2>/dev/null | grep -m1 -oE 'sha256:[a-f0-9]{64}' || true)"
    if [[ -z "$actual" || "$actual" != "$expected_digest" ]]; then
      echo "REFUSED: cannot prove digest match for $source (found: ${actual:-none})" >&2
      failed=$((failed+1)); continue
    fi
  fi
  if ! "${N[@]}" tag "$source" "$target"; then failed=$((failed+1)); continue; fi
  if ! "${N[@]}" push --platform "$PLATFORM" "$target"; then failed=$((failed+1)); continue; fi
  if [[ "$VERIFY_REMOTE" == true ]] && ! "${N[@]}" pull --platform "$PLATFORM" "$target"; then
    echo "FAILED destination verification: $target" >&2
    failed=$((failed+1)); continue
  fi
  ok=$((ok+1))
done < "$IMAGE_LIST"
echo "Completed: $ok succeeded, $failed failed"
(( failed == 0 ))
