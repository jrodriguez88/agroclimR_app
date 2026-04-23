# DSSAT container

This image builds DSSAT from the official open-source repository, following the same general approach used by Steven Sotelo's forecast Dockerfile: clone `DSSAT/dssat-csm-os`, create an out-of-source CMake build, compile, and copy the resulting executable into the runtime image.

Default executable expected inside the image:

```text
/opt/dssat/bin/dscsm048
```

Default build args:

```bash
DSSAT_REPO=https://github.com/DSSAT/dssat-csm-os.git
DSSAT_REF=v4.8.5.0
DSSAT_EXECUTABLE=dscsm048
DSSAT_BUILD_TYPE=RELEASE
```

Build with another branch/tag/commit:

```bash
docker build \
  --build-arg DSSAT_REF=v4.8.2.0 \
  -f docker/dssat/Dockerfile \
  .
```

Runtime contract:

```bash
crop-run dssat /path/to/work B DSSBatch.v47
```

The host folder is mounted as `/work`; DSSAT runs from `/work`; outputs persist in the mounted folder.

If the upstream executable name changes, update `DSSAT_EXECUTABLE`.
