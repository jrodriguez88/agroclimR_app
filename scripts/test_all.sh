#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

# shellcheck source=scripts/lib.sh
source scripts/lib.sh
load_env

require_command bash
require_command docker

example_workdir() {
  local model="$1"
  if [[ -d "inst/examples/${model}" ]]; then
    printf 'inst/examples/%s\n' "$model"
  else
    printf 'examples/%s\n' "$model"
  fi
}

example_args() {
  local model="$1"
  case "$model" in
    dssat)
      printf 'B DSSBatch.v48\n'
      ;;
    oryza)
      printf 'control.dat\n'
      ;;
    aquacrop)
      printf '\n'
      ;;
  esac
}

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
bash -n tests/dssat/test_entrypoint.sh
bash -n tests/oryza/test_entrypoint.sh
bash -n tests/aquacrop/test_entrypoint.sh

echo "Checking DSSAT runtime helpers..."
bash tests/dssat/test_entrypoint.sh

echo "Checking ORYZA path compatibility helpers..."
bash tests/oryza/test_entrypoint.sh

echo "Checking AquaCrop path compatibility helpers..."
bash tests/aquacrop/test_entrypoint.sh
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
    workdir="$(example_workdir "$model")"
    args="$(example_args "$model")"
    if docker image inspect "$image" >/dev/null 2>&1; then
      set +e
      if [[ -n "$args" ]]; then
        # shellcheck disable=SC2086
        output="$(docker run --rm --volume "$PWD/${workdir}:/work" --workdir /work "$image" $args 2>&1 | tr -d '\000')"
      else
        output="$(docker run --rm --volume "$PWD/${workdir}:/work" --workdir /work "$image" 2>&1 | tr -d '\000')"
      fi
      status=$?
      set -e
      if [[ "$status" -eq 127 ]]; then
        echo "${model}: missing executable message OK"
      elif [[ "$status" -eq 0 ]]; then
        echo "${model}: example run completed OK from ${workdir}"
      elif [[ "$model" == "dssat" && "$status" -eq 99 ]]; then
        echo "${model}: executable reached model startup from ${workdir}"
      elif [[ "$model" == "oryza" && "$status" -eq 24 ]]; then
        echo "${model}: executable reached input loading from ${workdir}"
      elif [[ "$model" == "aquacrop" && "$status" -eq 1 && "$output" == *"Failed to create LIST/ListProjectsTemp.txt"* ]]; then
        echo "${model}: executable requested a project structure from ${workdir}"
      elif [[ "$model" == "aquacrop" && "$status" -eq 1 && "$output" == *"Missing Environment and/or Simulation file(s):"* ]]; then
        echo "${model}: executable reached project parsing from ${workdir}"
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
