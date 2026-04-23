#!/usr/bin/env bash
set -euo pipefail

load_env() {
  if [[ -f .env ]]; then
    set -a
    # shellcheck disable=SC1091
    source .env
    set +a
  fi
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "error: missing required command: $1" >&2
    exit 1
  }
}

image_name() {
  local model="$1"
  local dockerhub_username="${DOCKERHUB_USERNAME:-DOCKERHUB_USERNAME}"
  local image_prefix="${IMAGE_PREFIX:-agroclimr-app}"
  local version="${VERSION:-0.1.0}"
  printf '%s/%s-%s:%s\n' "$dockerhub_username" "$image_prefix" "$model" "$version"
}

latest_image_name() {
  local model="$1"
  local dockerhub_username="${DOCKERHUB_USERNAME:-DOCKERHUB_USERNAME}"
  local image_prefix="${IMAGE_PREFIX:-agroclimr-app}"
  printf '%s/%s-%s:latest\n' "$dockerhub_username" "$image_prefix" "$model"
}

