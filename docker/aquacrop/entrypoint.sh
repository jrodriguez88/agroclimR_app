#!/usr/bin/env bash
set -euo pipefail

EXECUTABLE="${AQUACROP_EXECUTABLE:-aquacrop}"

if ! command -v "$EXECUTABLE" >/dev/null 2>&1; then
  cat >&2 <<EOF
AquaCrop executable not found: ${EXECUTABLE}

Place the official Linux AquaCrop executable at:
  docker/aquacrop/vendor/bin/${EXECUTABLE}

If your FAO package uses another executable name, set AQUACROP_EXECUTABLE at build time.
EOF
  exit 127
fi

cd /work
exec "$EXECUTABLE" "$@"

