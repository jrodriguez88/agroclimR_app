#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

require_command() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "missing: $1" >&2
    missing=1
  }
}

missing=0
require_command bash
require_command git
require_command docker

chmod +x bin/crop-run
chmod +x scripts/*.sh
chmod +x docker/dssat/entrypoint.sh docker/oryza/entrypoint.sh docker/aquacrop/entrypoint.sh

if [[ "$missing" -ne 0 ]]; then
  echo "Install the missing dependencies and rerun this script." >&2
  exit 1
fi

if docker info >/dev/null 2>&1; then
  echo "Docker is available."
else
  echo "Docker CLI exists, but the daemon is unavailable. Check Docker Desktop WSL2 integration." >&2
fi

echo "Local setup complete."
echo "Add this project launcher to PATH with:"
echo "  export PATH=\"$PWD/bin:\$PATH\""

