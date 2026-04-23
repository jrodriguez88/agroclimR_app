#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

# shellcheck source=scripts/lib.sh
source scripts/lib.sh
load_env

require_command bash
require_command docker

echo "Checking bash syntax..."
bash -n bin/crop-run
bash -n scripts/lib.sh
bash -n scripts/build_all.sh
bash -n scripts/test_all.sh
bash -n scripts/publish_all.sh
bash -n scripts/init_repo.sh
bash -n scripts/setup_local.sh
bash -n docker/dssat/entrypoint.sh
bash -n docker/oryza/entrypoint.sh
bash -n docker/aquacrop/entrypoint.sh

echo "Checking launcher help..."
bin/crop-run --help >/dev/null

echo "Checking expected structure..."
for model in dssat oryza aquacrop; do
  [[ -f "docker/${model}/Dockerfile" ]]
  [[ -f "docker/${model}/entrypoint.sh" ]]
  [[ -d "tests/${model}" ]]
  [[ -d "examples/${model}" ]]
done

if docker info >/dev/null 2>&1; then
  echo "Checking container startup behavior..."
  for model in dssat oryza aquacrop; do
    image="$(image_name "$model")"
    if docker image inspect "$image" >/dev/null 2>&1; then
      set +e
      output="$(docker run --rm --volume "$PWD/examples/${model}:/work" --workdir /work "$image" 2>&1)"
      status=$?
      set -e
      if [[ "$status" -eq 127 ]]; then
        echo "${model}: missing executable message OK"
      elif [[ "$status" -eq 0 ]]; then
        echo "${model}: executable started OK"
      else
        echo "$output" >&2
        echo "error: ${model} container returned unexpected status ${status}" >&2
        exit "$status"
      fi
    else
      echo "${model}: image not built yet, skipping runtime check (${image})"
    fi
  done
else
  echo "Docker daemon unavailable; skipped runtime checks."
fi

echo "All tests passed."

