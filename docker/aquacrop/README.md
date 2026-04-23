# AquaCrop container

This image builds AquaCrop from the official KUL-RSDA open-source Fortran repository by default. AquaCrop v7.0 and newer are published as open-source Fortran code endorsed by FAO, and the upstream build is `cd src && make`.

Default executable expected inside the image:

```text
/opt/aquacrop/bin/aquacrop
```

Default build args:

```bash
AQUACROP_REPO=https://github.com/KUL-RSDA/AquaCrop.git
AQUACROP_REF=v7.3_typofix
AQUACROP_EXECUTABLE=aquacrop
```

Build with another tag or branch:

```bash
docker build \
  --build-arg AQUACROP_REF=v7.2 \
  -f docker/aquacrop/Dockerfile \
  .
```

If you prefer the official standalone binary you downloaded, place it at `docker/aquacrop/vendor/bin/aquacrop`. That file is copied after the source-built binary and therefore overrides it.

Runtime contract:

```bash
crop-run aquacrop /path/to/work
```

The host folder is mounted as `/work`; AquaCrop runs from `/work`; outputs persist in the mounted folder.
