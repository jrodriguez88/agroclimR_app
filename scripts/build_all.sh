#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

# shellcheck source=scripts/lib.sh
source scripts/lib.sh
load_env
require_command docker

models=(dssat oryza aquacrop)

for model in "${models[@]}"; do
  versioned="$(image_name "$model")"
  latest="$(latest_image_name "$model")"
  echo "Building ${versioned}"
  docker build \
    --file "docker/${model}/Dockerfile" \
    --tag "$versioned" \
    .

  if [[ "${TAG_LATEST:-true}" == "true" ]]; then
    docker tag "$versioned" "$latest"
    echo "Tagged ${latest}"
  fi
done

echo "All images built."

