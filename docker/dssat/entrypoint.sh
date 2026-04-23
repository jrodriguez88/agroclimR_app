#!/usr/bin/env bash
set -euo pipefail

EXECUTABLE="${DSSAT_EXECUTABLE:-dscsm048}"

if ! command -v "$EXECUTABLE" >/dev/null 2>&1; then
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
fi

cd /work
exec "$EXECUTABLE" "$@"

