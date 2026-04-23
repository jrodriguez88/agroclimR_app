# AquaCrop container

This image expects a Linux AquaCrop stand-alone executable supplied by the user. The repository does not download or redistribute AquaCrop.

Default executable expected inside the image:

```text
/opt/aquacrop/bin/aquacrop
```

Local source path before build:

```text
docker/aquacrop/vendor/bin/aquacrop
```

If your FAO package uses another filename:

```bash
docker build --build-arg AQUACROP_EXECUTABLE=my_aquacrop_binary -f docker/aquacrop/Dockerfile .
```

Runtime contract:

```bash
crop-run aquacrop /path/to/work
```

The host folder is mounted as `/work`; AquaCrop runs from `/work`; outputs persist in the mounted folder.

