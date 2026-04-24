# Usage

## Prepare the shell

```bash
cp .env.example .env
./scripts/setup_local.sh
export PATH="$PWD/bin:$PATH"
```

Edit `.env` with your Docker Hub namespace before building images.

## Build images

```bash
./scripts/build_all.sh
```

## Run models

ORYZA:

```bash
crop-run oryza ~/forecast/test/oryza
```

DSSAT batch mode:

```bash
crop-run dssat ~/forecast/test/dssat B DSSBatch.v47
```

AquaCrop:

```bash
crop-run aquacrop ~/forecast/test/aquacrop
```

## Run local example cases

If you keep local validation datasets under `inst/examples`, you can run them directly:

```bash
crop-run dssat "$PWD/inst/examples/dssat" B DSSBatch.v48
crop-run oryza "$PWD/inst/examples/oryza" control.dat
crop-run aquacrop "$PWD/inst/examples/aquacrop"
```

`scripts/test_all.sh` prefers `inst/examples/<model>` when those folders exist.

## Optional alias

```bash
alias agroclim-run='crop-run'
agroclim-run dssat ~/forecast/test/dssat B DSSBatch.v47
```

## Common errors

`Docker is unavailable`

Docker Desktop is not running or WSL2 integration is disabled for Debian.

`Input folder does not exist`

Create the folder first or pass the correct Linux path. Prefer `~/forecast/...` over `/mnt/c/...`.

`executable not found`

The image was built without the real model executable. Place the Linux executable under the matching `docker/<model>/vendor/bin/` folder and rebuild.

`pull access denied`

The image name uses the placeholder `DOCKERHUB_USERNAME`. Set `DOCKERHUB_USERNAME` in `.env`, rebuild and rerun.
