# DSSAT container

This image is intentionally prepared as a scaffold. It does not download DSSAT or include external binaries.

Default executable expected inside the image:

```text
/opt/dssat/bin/dscsm048
```

Local source path before build:

```text
docker/dssat/vendor/bin/dscsm048
```

If your DSSAT Linux executable has another name, build with:

```bash
docker build --build-arg DSSAT_EXECUTABLE=my_dssat -f docker/dssat/Dockerfile .
```

Runtime contract:

```bash
crop-run dssat /path/to/work B DSSBatch.v47
```

The host folder is mounted as `/work`; DSSAT runs from `/work`; outputs persist in the mounted folder.

