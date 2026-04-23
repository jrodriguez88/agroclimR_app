#!/usr/bin/env bash
set -euo pipefail

EXECUTABLE="${ORYZA_EXECUTABLE:-oryza}"

if ! command -v "$EXECUTABLE" >/dev/null 2>&1; then
  cat >&2 <<EOF
ORYZA executable not found: ${EXECUTABLE}

Place the Linux ORYZA executable at:
  docker/oryza/vendor/bin/${EXECUTABLE}

If your release uses another executable name, set ORYZA_EXECUTABLE at build time.
EOF
  exit 127
fi

cd /work
exec "$EXECUTABLE" "$@"

