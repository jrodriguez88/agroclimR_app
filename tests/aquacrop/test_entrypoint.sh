#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/../.."

# shellcheck source=docker/aquacrop/entrypoint.sh
source docker/aquacrop/entrypoint.sh

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

mkdir -p "$tmpdir/WTH" "$tmpdir/SOIL"
printf 'temp\n' > "$tmpdir/WTH/AIHU.Tnx"
printf 'eto\n' > "$tmpdir/WTH/AIHU.ETo"
printf 'rain\n' > "$tmpdir/WTH/AIHU.PLU"
printf 'co2\n' > "$tmpdir/MaunaLoa.CO2"
printf 'soil\n' > "$tmpdir/SOIL/AIHU.SOL"

prepare_windows_relative_aliases "$tmpdir"

[[ -L "$tmpdir/WTH\\AIHU.Tnx" ]]
[[ "$(readlink "$tmpdir/WTH\\AIHU.Tnx")" == "WTH/AIHU.Tnx" ]]

[[ -L "$tmpdir/.\\WTH\\AIHU.ETo" ]]
[[ "$(readlink "$tmpdir/.\\WTH\\AIHU.ETo")" == "WTH/AIHU.ETo" ]]

[[ -L "$tmpdir/.\\MaunaLoa.CO2" ]]
[[ "$(readlink "$tmpdir/.\\MaunaLoa.CO2")" == "MaunaLoa.CO2" ]]

[[ -L "$tmpdir/.MaunaLoa.CO2" ]]
[[ "$(readlink "$tmpdir/.MaunaLoa.CO2")" == "MaunaLoa.CO2" ]]

[[ -L "$tmpdir/.AIHU.Tnx" ]]
[[ "$(readlink "$tmpdir/.AIHU.Tnx")" == "WTH/AIHU.Tnx" ]]

[[ -L "$tmpdir/SOIL\\AIHU.SOL" ]]
[[ "$(readlink "$tmpdir/SOIL\\AIHU.SOL")" == "SOIL/AIHU.SOL" ]]

echo "AquaCrop entrypoint alias test passed."
