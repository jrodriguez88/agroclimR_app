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
  build_args=()

  case "$model" in
    dssat)
      build_args+=(
        --build-arg "DSSAT_REPO=${DSSAT_REPO:-https://github.com/DSSAT/dssat-csm-os.git}"
        --build-arg "DSSAT_REF=${DSSAT_REF:-v4.8.5.0}"
        --build-arg "DSSAT_EXECUTABLE=${DSSAT_EXECUTABLE:-dscsm048}"
        --build-arg "DSSAT_BUILD_TYPE=${DSSAT_BUILD_TYPE:-RELEASE}"
      )
      ;;
    aquacrop)
      build_args+=(
        --build-arg "AQUACROP_REPO=${AQUACROP_REPO:-https://github.com/KUL-RSDA/AquaCrop.git}"
        --build-arg "AQUACROP_REF=${AQUACROP_REF:-v7.3_typofix}"
        --build-arg "AQUACROP_EXECUTABLE=${AQUACROP_EXECUTABLE:-aquacrop}"
      )
      ;;
  esac

  echo "Building ${versioned}"
  docker build \
    --file "docker/${model}/Dockerfile" \
    --tag "$versioned" \
    "${build_args[@]}" \
    .

  if [[ "${TAG_LATEST:-true}" == "true" ]]; then
    docker tag "$versioned" "$latest"
    echo "Tagged ${latest}"
  fi
done

echo "All images built."
