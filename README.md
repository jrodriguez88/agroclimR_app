# agroclimR_app

`agroclimR_app` is a reproducible Docker-based launcher for running crop simulation models from Debian/WSL, Linux, or any shell with Docker available. It exposes one command, `crop-run`, and routes each model to an isolated container image:

- DSSAT
- ORYZA
- AquaCrop

The intended user interface is stable:

```bash
crop-run oryza ~/forecast/test/oryza
crop-run dssat ~/forecast/test/dssat B DSSBatch.v47
crop-run aquacrop ~/forecast/test/aquacrop
```

Input and output files stay in the host folder selected by the user. The container mounts that folder as `/work`, runs the selected model from there, writes outputs back to the same folder, and exits.

## Why This Project Exists

Crop model workflows often depend on a fragile mix of operating system packages, executable names, model-specific conventions, and licensing constraints. This project keeps those concerns isolated behind model-specific Docker images while giving users a single launcher command for day-to-day execution.

The repository contains only the wrapper, Dockerfiles, scripts, documentation, and empty placeholders for local assets. Licensed binaries, installers, private datasets, and credentials are intentionally excluded from Git.

## Architecture

The project uses three independent images so each model can evolve without leaking dependencies or assumptions into the others:

```text
DOCKERHUB_USERNAME/agroclimr-app-dssat:0.1.0
DOCKERHUB_USERNAME/agroclimr-app-oryza:0.1.0
DOCKERHUB_USERNAME/agroclimr-app-aquacrop:0.1.0
```

The launcher at `bin/crop-run` validates arguments, resolves the host input folder, selects the matching image, mounts the folder as `/work`, and forwards any extra arguments unchanged to the container entrypoint.

## Requirements

- Debian on WSL2 or a Linux environment with Docker.
- Docker Desktop with WSL2 integration enabled when using Windows.
- `bash`, `git`, and `docker`.
- Optional: GitHub CLI (`gh`) for repository bootstrapping.

For WSL2, work from the Linux filesystem when possible:

```bash
cd ~
git clone https://github.com/jrodriguez88/agroclimR_app.git
cd agroclimR_app
```

Avoid heavy model runs from `/mnt/c/...` because bind mounts are usually slower there.

## Configuration

Copy the sample environment file:

```bash
cp .env.example .env
```

Review and adjust at least:

```bash
GITHUB_USERNAME=your_github_username
DOCKERHUB_USERNAME=your_dockerhub_namespace
PROJECT_NAME=agroclimR_app
VERSION=0.1.0
```

Optional build source settings:

```bash
DSSAT_REF=v4.8.5.0
AQUACROP_REF=v7.3_typofix
```

Prepare local permissions and check basic dependencies:

```bash
./scripts/setup_local.sh
```

Expose the launcher in your current shell:

```bash
export PATH="$PWD/bin:$PATH"
```

Optional alias:

```bash
alias agroclim-run='crop-run'
```

## Model Artifacts

DSSAT is built from `https://github.com/DSSAT/dssat-csm-os.git` using CMake and GNU Fortran.

AquaCrop is built from `https://github.com/KUL-RSDA/AquaCrop.git` with `make` in `src`.

ORYZA is not downloaded by this repository. Provide a Linux executable locally when your license and distribution terms allow it.

Local artifact paths:

```text
docker/oryza/vendor/bin/oryza
docker/aquacrop/vendor/bin/aquacrop
docker/dssat/vendor/bin/dscsm048
```

The AquaCrop and DSSAT vendor binaries are optional overrides. If present, they replace the executable built from source. ORYZA requires a supplied executable unless you customize the image.

You can change the expected executable names with build arguments:

```bash
docker build --build-arg ORYZA_EXECUTABLE=my_oryza -f docker/oryza/Dockerfile .
docker build --build-arg AQUACROP_EXECUTABLE=my_aquacrop -f docker/aquacrop/Dockerfile .
docker build --build-arg DSSAT_EXECUTABLE=my_dssat -f docker/dssat/Dockerfile .
```

If the ORYZA executable is missing, the image can still build and will fail at runtime with a clear message. This keeps Docker, CI, and repository checks usable without redistributing restricted assets.

## Build Images

```bash
./scripts/build_all.sh
```

The script loads `.env` when present, builds the three images, and tags each one with `VERSION` and, when `TAG_LATEST=true`, `latest`.

## Run Checks

```bash
./scripts/test_all.sh
```

The test script validates Bash syntax, launcher help output, expected repository structure, and controlled container startup behavior.

If local example cases are available under `inst/examples/<model>`, the runtime check prefers those folders:

```text
inst/examples/dssat
inst/examples/oryza
inst/examples/aquacrop
```

Those folders are intended for local validation only and stay ignored by Git.

## Usage

```bash
crop-run oryza ~/forecast/test/oryza
crop-run dssat ~/forecast/test/dssat B DSSBatch.v47
crop-run aquacrop ~/forecast/test/aquacrop
```

With local example cases staged under `inst/examples`, you can also run:

```bash
crop-run dssat "$PWD/inst/examples/dssat" B DSSBatch.v48
crop-run oryza "$PWD/inst/examples/oryza" control.dat
crop-run aquacrop "$PWD/inst/examples/aquacrop"
```

You can override the namespace or image version for a single command:

```bash
DOCKERHUB_USERNAME=myuser VERSION=0.1.0 crop-run dssat ~/forecast/test/dssat B DSSBatch.v47
```

## Publish To GitHub

Before pushing, confirm that no private files are staged:

```bash
git status --short
git diff --cached --name-only
```

Files such as `.env`, installers, model binaries, private datasets, and local runtime output must stay out of Git. The repository `.gitignore` excludes those paths by default.

Push the repository:

```bash
git push -u origin main
```

## Publish To Docker Hub

Authenticate first:

```bash
docker login
```

Build and publish all images:

```bash
./scripts/build_all.sh
./scripts/publish_all.sh
```

The publish script pushes all three model images with `VERSION` and, when enabled, `latest`.

## Security And Distribution Notes

- Do not commit `.env`, tokens, credentials, private model inputs, licensed installers, or restricted binaries.
- Docker images may include local vendor executables if they are present during the build. Only publish images that you are legally allowed to redistribute.
- This repository licenses only the wrapper, scripts, documentation, and scaffold code under MIT.
- Model packages may have their own licenses, citation requirements, and redistribution limits.

## Current Limitations

- DSSAT, ORYZA, and AquaCrop may require artifacts with separate distribution terms.
- ORYZA must be validated with the exact Linux package available to the user.
- Entrypoints assume default executable names unless overridden at build time.
- Regression tests currently validate structure and startup behavior, not scientific output.

## Roadmap

- Validate one lightweight, license-safe sample case per model.
- Add regression tests using permitted input datasets.
- Add CI checks for shell syntax and documentation links.
- Publish versioned Docker images after license review.
