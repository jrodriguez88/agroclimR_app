# Model notes

## DSSAT

DSSAT has Linux-oriented build workflows in official materials, commonly involving Fortran tooling. This scaffold does not download sources automatically. Use one of these approaches:

- place a compiled Linux executable at `docker/dssat/vendor/bin/dscsm048`;
- place source or installers in `docker/dssat/vendor/source` or `docker/dssat/vendor/installers` and extend the Dockerfile with the exact official build steps you choose.

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

AquaCrop stand-alone Linux releases are suited to non-GUI batch execution, but the exact archive layout and executable name can vary by package.

Default expected executable:

```text
docker/aquacrop/vendor/bin/aquacrop
```

If your package uses another name, change `AQUACROP_EXECUTABLE` at build time or rename the executable before building.

## Manual assets

The repository ignores model binaries and installers by default. Keep private or licensed artifacts out of Git and Docker Hub unless their license explicitly permits redistribution.

