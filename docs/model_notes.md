# Model notes

## DSSAT

DSSAT has Linux-oriented build workflows in official materials using CMake and Fortran tooling. This image now clones the official `DSSAT/dssat-csm-os` repository, builds out-of-source with CMake, and copies `dscsm048` into `/opt/dssat/bin`.

The local `docker/dssat/vendor/bin/dscsm048` path remains available as an override if you need to test a patched executable.

Default runtime:

```bash
crop-run dssat /path/to/work B DSSBatch.v47
```

Extra args are passed unchanged.

## ORYZA

ORYZA Linux packages can differ by release and executable name. The default expected executable is:

```text
docker/oryza/vendor/bin/oryza
```

If your release uses a different name, change `ORYZA_EXECUTABLE` at build time or rename the executable before building.

## AquaCrop

AquaCrop v7.0+ is available as open-source Fortran from `KUL-RSDA/AquaCrop`. The image builds it with `make -C src` and copies the resulting `aquacrop` executable.

Default executable:

```text
docker/aquacrop/vendor/bin/aquacrop
```

If you provide `docker/aquacrop/vendor/bin/aquacrop`, it overrides the source-built executable. This is useful when validating the official standalone binary package you downloaded.

## Manual assets

The repository ignores model binaries and installers by default. Keep private or licensed artifacts out of Git and Docker Hub unless their license explicitly permits redistribution.
