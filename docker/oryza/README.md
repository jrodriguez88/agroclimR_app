# ORYZA container

This image expects a Linux ORYZA executable supplied by the user. The repository does not download or redistribute ORYZA.

Default executable expected inside the image:

```text
/opt/oryza/bin/oryza
```

Local source path before build:

```text
docker/oryza/vendor/bin/oryza
```

If your IRRI package uses another filename:

```bash
docker build --build-arg ORYZA_EXECUTABLE=my_oryza_binary -f docker/oryza/Dockerfile .
```

Runtime contract:

```bash
crop-run oryza /path/to/work
```

The host folder is mounted as `/work`; ORYZA runs from `/work`; outputs persist in the mounted folder.

