#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/../.."

# shellcheck source=docker/dssat/entrypoint.sh
source docker/dssat/entrypoint.sh

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

runtime_root="$tmpdir/runtime"
data_root="$tmpdir/data"
workdir="$tmpdir/work"
usr_local_root="$tmpdir/usr-local"
mkdir -p "$runtime_root" "$data_root/StandardData" "$workdir" "$usr_local_root"

printf 'model error\n' > "$data_root/MODEL.ERR"
printf 'co2\n' > "$data_root/StandardData/CO2048.WDA"
printf '#!/usr/bin/env bash\nexit 0\n' > "$tmpdir/dscsm048"
chmod +x "$tmpdir/dscsm048"

DSSAT_HOME="$runtime_root" DSSAT_DATA="$data_root" DSSAT_USR_LOCAL="$usr_local_root" stage_dssat_runtime "$tmpdir/dscsm048" "$workdir"

[[ -L "$runtime_root/DSCSM048.EXE" ]]
[[ "$(readlink "$runtime_root/DSCSM048.EXE")" == "$tmpdir/dscsm048" ]]

[[ -L "$workdir/DSCSM048.EXE" ]]
[[ "$(readlink "$workdir/DSCSM048.EXE")" == "$tmpdir/dscsm048" ]]

[[ -L "$runtime_root/MODEL.ERR" ]]
[[ "$(readlink "$runtime_root/MODEL.ERR")" == "$data_root/MODEL.ERR" ]]

[[ -L "$workdir/MODEL.ERR" ]]
[[ "$(readlink "$workdir/MODEL.ERR")" == "$data_root/MODEL.ERR" ]]

[[ -L "$runtime_root/StandardData" ]]
[[ "$(readlink "$runtime_root/StandardData")" == "$data_root/StandardData" ]]

[[ -L "$workdir/StandardData" ]]
[[ "$(readlink "$workdir/StandardData")" == "$data_root/StandardData" ]]

[[ -L "$usr_local_root/StandardData" ]]
[[ "$(readlink "$usr_local_root/StandardData")" == "$data_root/StandardData" ]]

echo "DSSAT entrypoint runtime test passed."
