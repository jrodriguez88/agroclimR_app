# Architecture

`agroclimR_app` separates model runtime concerns from user workflow.

## Three independent images

Each model has its own Docker image:

- `agroclimr-app-dssat`
- `agroclimr-app-oryza`
- `agroclimr-app-aquacrop`

This keeps dependencies, executable names, licenses and debugging isolated. A DSSAT change should not affect AquaCrop or ORYZA.

## Launcher flow

The launcher command is:

```bash
crop-run <modelo> <carpeta_inputs> [args_extra]
```

It performs these steps:

1. validates the model name;
2. checks Docker availability;
3. checks that the input folder exists;
4. resolves the input folder to an absolute path;
5. selects the image name from `DOCKERHUB_USERNAME`, `IMAGE_PREFIX` and `VERSION`;
6. runs Docker with the input folder mounted at `/work`;
7. passes any extra arguments unchanged to the model entrypoint.

## Volumes and persistence

The host directory is mounted as:

```text
host_input_folder:/work
```

The container uses `/work` as working directory. Any output written by the model into the current directory persists directly in the host folder.

## Image versioning

Images use this convention:

```text
DOCKERHUB_USERNAME/agroclimr-app-dssat:0.1.0
DOCKERHUB_USERNAME/agroclimr-app-oryza:0.1.0
DOCKERHUB_USERNAME/agroclimr-app-aquacrop:0.1.0
```

`scripts/build_all.sh` also tags `latest` when `TAG_LATEST=true`.

