#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/../.."

# shellcheck source=docker/oryza/entrypoint.sh
source docker/oryza/entrypoint.sh

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

mkdir -p "$tmpdir/WTH" "$tmpdir/EXP" "$tmpdir/SOIL"
printf 'weather\n' > "$tmpdir/WTH/AIHU1.014"
printf 'exp\n' > "$tmpdir/EXP/AIHU_FED2000_MADRI_S1.exp"
printf 'soil\n' > "$tmpdir/SOIL/AIHU.sol"
printf 'crop\n' > "$tmpdir/F2000.crp"
printf 'rer\n' > "$tmpdir/F2000_to_comparison_reruns.rer"

prepare_windows_relative_aliases "$tmpdir"

[[ -L "$tmpdir/WTH\\AIHU1.014" ]]
[[ "$(readlink "$tmpdir/WTH\\AIHU1.014")" == "WTH/AIHU1.014" ]]

[[ -L "$tmpdir/EXP\\AIHU_FED2000_MADRI_S1.exp" ]]
[[ "$(readlink "$tmpdir/EXP\\AIHU_FED2000_MADRI_S1.exp")" == "EXP/AIHU_FED2000_MADRI_S1.exp" ]]

[[ -L "$tmpdir/SOIL\\AIHU.sol" ]]
[[ "$(readlink "$tmpdir/SOIL\\AIHU.sol")" == "SOIL/AIHU.sol" ]]

[[ -L "$tmpdir/.\\WTH\\AIHU1.014" ]]
[[ "$(readlink "$tmpdir/.\\WTH\\AIHU1.014")" == "WTH/AIHU1.014" ]]

echo "ORYZA entrypoint alias test passed."
