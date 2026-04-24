#!/usr/bin/env bash
set -euo pipefail

EXECUTABLE="${AQUACROP_EXECUTABLE:-aquacrop}"

create_alias() {
  local target="$1"
  local alias_name="$2"

  [[ -n "$alias_name" ]] || return 0
  [[ "$alias_name" == "$target" ]] && return 0
  [[ -e "$alias_name" || -L "$alias_name" ]] && return 0

  ln -s "$target" "$alias_name"
}

prepare_windows_relative_aliases() {
  local workdir="${1:-/work}"
  [[ -d "$workdir" ]] || return 0

  (
    cd "$workdir"

    while IFS= read -r -d '' source_path; do
      local rel
      local windows_rel

      rel="${source_path#./}"

      # Skip aliases we created on previous runs.
      case "$rel" in
        *\\*)
          continue
          ;;
      esac

      windows_rel="${rel//\//\\}"
      create_alias "$rel" "$windows_rel"
      create_alias "$rel" ".\\$windows_rel"
      create_alias "$rel" ".${rel##*/}"
    done < <(find . -type f -print0)
  )
}

require_executable() {
  if command -v "$EXECUTABLE" >/dev/null 2>&1; then
    return 0
  fi

  cat >&2 <<EOF
AquaCrop executable not found: ${EXECUTABLE}

Place the official Linux AquaCrop executable at:
  docker/aquacrop/vendor/bin/${EXECUTABLE}

If your FAO package uses another executable name, set AQUACROP_EXECUTABLE at build time.
EOF
  exit 127
}

main() {
  require_executable
  prepare_windows_relative_aliases /work
  cd /work
  exec "$EXECUTABLE" "$@"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
