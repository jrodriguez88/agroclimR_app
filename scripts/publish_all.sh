#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

# shellcheck source=scripts/lib.sh
source scripts/lib.sh
load_env
require_command docker

docker info >/dev/null 2>&1 || {
  echo "error: Docker is unavailable. Run docker login after Docker Desktop WSL integration is ready." >&2
  exit 1
}

if [[ "${DOCKERHUB_USERNAME:-DOCKERHUB_USERNAME}" == "DOCKERHUB_USERNAME" ]]; then
  echo "error: set DOCKERHUB_USERNAME in .env before publishing." >&2
  exit 1
fi

models=(dssat oryza aquacrop)

for model in "${models[@]}"; do
  versioned="$(image_name "$model")"
  latest="$(latest_image_name "$model")"
  echo "Publishing ${versioned}"
  docker push "$versioned"

  if [[ "${TAG_LATEST:-true}" == "true" ]]; then
    echo "Publishing ${latest}"
    docker push "$latest"
  fi
done

echo "Published images:"
for model in "${models[@]}"; do
  echo "  $(image_name "$model")"
  if [[ "${TAG_LATEST:-true}" == "true" ]]; then
    echo "  $(latest_image_name "$model")"
  fi
done

