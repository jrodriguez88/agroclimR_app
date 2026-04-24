#!/usr/bin/env bash
set -euo pipefail

EXECUTABLE="${DSSAT_EXECUTABLE:-dscsm048}"
EXECUTABLE_UPPER="${DSSAT_EXECUTABLE_UPPER:-DSCSM048.EXE}"

create_link() {
  local target="$1"
  local link_path="$2"

  [[ -e "$target" || -L "$target" ]] || return 0
  [[ -e "$link_path" || -L "$link_path" ]] && return 0

  ln -s "$target" "$link_path"
}

stage_dssat_runtime() {
  local executable_path="$1"
  local workdir="${2:-/work}"
  local runtime_root="${DSSAT_HOME:-/opt/dssat}"
  local data_root="${DSSAT_DATA:-/opt/dssat/data}"
  local usr_local_root="${DSSAT_USR_LOCAL:-/usr/local}"

  mkdir -p "$runtime_root" "$workdir"

  create_link "$executable_path" "$runtime_root/${EXECUTABLE_UPPER}"
  create_link "$executable_path" "$workdir/${EXECUTABLE_UPPER}"

  if [[ -d "$data_root" ]]; then
    while IFS= read -r -d '' source_path; do
      local name
      name="$(basename "$source_path")"
      create_link "$source_path" "$workdir/$name"
    done < <(find "$data_root" -mindepth 1 -maxdepth 1 -print0)

    if [[ -d "$data_root/StandardData" ]]; then
      create_link "$data_root/StandardData" "$runtime_root/StandardData"
      create_link "$data_root/StandardData" "$workdir/StandardData"
      create_link "$data_root/StandardData" "$usr_local_root/StandardData"
    fi

    if [[ -f "$data_root/MODEL.ERR" ]]; then
      create_link "$data_root/MODEL.ERR" "$runtime_root/MODEL.ERR"
      create_link "$data_root/MODEL.ERR" "$workdir/MODEL.ERR"
    fi
  fi
}

require_executable() {
  if command -v "$EXECUTABLE" >/dev/null 2>&1; then
    return 0
  fi

  cat >&2 <<EOF
DSSAT executable not found: ${EXECUTABLE}

Place a Linux DSSAT executable at:
  docker/dssat/vendor/bin/${EXECUTABLE}

Then rebuild the image with:
  ./scripts/build_all.sh

For batch mode, the launcher passes extra args as-is, for example:
  crop-run dssat /path/to/work B DSSBatch.v47
EOF
  exit 127
}

main() {
  local executable_path

  require_executable
  executable_path="$(command -v "$EXECUTABLE")"
  stage_dssat_runtime "$executable_path" /work
  cd /work
  exec "$EXECUTABLE" "$@"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
