# agroclimR_app

`agroclimR_app` es un wrapper reproducible para ejecutar modelos de simulacion de cultivos desde Debian/WSL usando Docker. El proyecto ofrece un unico comando, `crop-run`, que despacha a tres imagenes independientes:

- DSSAT
- ORYZA
- AquaCrop

La interfaz buscada es estable:

```bash
crop-run oryza ~/forecast/test/oryza
crop-run dssat ~/forecast/test/dssat B DSSBatch.v47
crop-run aquacrop ~/forecast/test/aquacrop
```

Los inputs y outputs viven en la carpeta local indicada por el usuario. El contenedor la monta como `/work`, ejecuta el modelo desde alli y termina.

## Arquitectura

El proyecto usa tres imagenes separadas para evitar mezclar dependencias, licencias, binarios y supuestos de ejecucion:

```text
DOCKERHUB_USERNAME/agroclimr-app-dssat:0.1.0
DOCKERHUB_USERNAME/agroclimr-app-oryza:0.1.0
DOCKERHUB_USERNAME/agroclimr-app-aquacrop:0.1.0
```

El launcher `bin/crop-run` selecciona la imagen correcta, valida argumentos, resuelve rutas absolutas, monta la carpeta como `/work` y pasa argumentos extra sin romper quoting.

## Requisitos previos

- Debian sobre WSL2.
- Docker Desktop con integracion WSL2 habilitada para la distro Debian.
- `bash`, `git` y `docker` disponibles en la distro.
- Opcional: GitHub CLI (`gh`) para crear y publicar el repositorio.

Trabaja preferiblemente dentro del filesystem Linux de WSL, por ejemplo:

```bash
cd ~
git clone https://github.com/GITHUB_USERNAME/agroclimR_app.git
cd agroclimR_app
```

Evita ejecutar cargas pesadas desde `/mnt/c/...` porque los bind mounts suelen ser mas lentos.

## Configuracion

Copia el archivo de ejemplo:

```bash
cp .env.example .env
```

Edita al menos:

```bash
GITHUB_USERNAME=tu_usuario_github
DOCKERHUB_USERNAME=tu_usuario_dockerhub
PROJECT_NAME=agroclimR_app
VERSION=0.1.0
```

Opcionalmente fija las fuentes usadas en los builds:

```bash
DSSAT_REF=v4.8.5.0
AQUACROP_REF=v7.3_typofix
```

Luego prepara permisos y dependencias basicas:

```bash
./scripts/setup_local.sh
```

Para tener `crop-run` disponible en la shell:

```bash
export PATH="$PWD/bin:$PATH"
```

Alias opcional:

```bash
alias agroclim-run='crop-run'
```

## Artefactos y fuentes de modelos

DSSAT se construye desde `https://github.com/DSSAT/dssat-csm-os.git` usando CMake y GNU Fortran, de forma similar al Dockerfile de referencia de Steven Sotelo, pero aislado en su propia imagen.

AquaCrop se construye desde `https://github.com/KUL-RSDA/AquaCrop.git` usando `make` en `src`, siguiendo la documentacion oficial del proyecto open-source.

Este repositorio no incluye binarios propietarios, instaladores oficiales ni datasets pesados. Si ya descargaste instaladores Linux para ORYZA o AquaCrop, copialos primero a `inst/` como area de trabajo local y luego coloca el ejecutable final en la carpeta `vendor/bin` del modelo correspondiente.

Rutas esperadas por defecto:

```text
docker/oryza/vendor/bin/oryza
docker/aquacrop/vendor/bin/aquacrop
```

`docker/aquacrop/vendor/bin/aquacrop` es opcional: si existe, sobrescribe el binario compilado desde fuente. Para DSSAT, `docker/dssat/vendor/bin/dscsm048` tambien puede sobrescribir el binario compilado.

Tambien puedes cambiar el nombre esperado con build args:

```bash
docker build --build-arg ORYZA_EXECUTABLE=mi_oryza -f docker/oryza/Dockerfile .
docker build --build-arg AQUACROP_EXECUTABLE=mi_aquacrop -f docker/aquacrop/Dockerfile .
docker build --build-arg DSSAT_EXECUTABLE=mi_dssat -f docker/dssat/Dockerfile .
```

Si falta el binario ORYZA, la imagen se construye igual y el contenedor falla con un mensaje controlado. Esto permite validar estructura, CI local y flujo Docker sin inventar descargas.

## Construir imagenes

```bash
./scripts/build_all.sh
```

El script carga `.env` si existe, construye las tres imagenes y etiqueta cada una con `VERSION` y `latest`.

## Pruebas

```bash
./scripts/test_all.sh
```

Las pruebas validan sintaxis bash, `crop-run --help`, estructura esperada y arranque controlado de los contenedores. Si faltan binarios reales, el test acepta los mensajes de artefacto faltante.

## Uso

Con las imagenes construidas:

```bash
crop-run oryza ~/forecast/test/oryza
crop-run dssat ~/forecast/test/dssat B DSSBatch.v47
crop-run aquacrop ~/forecast/test/aquacrop
```

Tambien puedes usar variables para apuntar a otro registry o version:

```bash
DOCKERHUB_USERNAME=miusuario VERSION=0.1.0 crop-run dssat ~/forecast/test/dssat B DSSBatch.v47
```

## Publicar en GitHub

Si `gh` esta instalado y autenticado:

```bash
./scripts/init_repo.sh
```

El script inicializa Git si hace falta, crea commits iniciales si no existen y puede crear el remoto `GITHUB_USERNAME/agroclimR_app`.

Si prefieres hacerlo manualmente:

```bash
git remote add origin https://github.com/GITHUB_USERNAME/agroclimR_app.git
git push -u origin main
```

No guardes tokens ni credenciales dentro del repositorio.

## Publicar en Docker Hub

Inicia sesion primero:

```bash
docker login
```

Luego publica:

```bash
./scripts/publish_all.sh
```

El script publica las tres imagenes con `VERSION` y `latest`.

## Limitaciones actuales

- DSSAT, ORYZA y AquaCrop pueden requerir binarios, fuentes o instaladores con condiciones de distribucion propias.
- Este repositorio licencia solo el wrapper, scripts y scaffold propio bajo MIT.
- Los entrypoints asumen nombres de ejecutable por defecto; ajustalos si tu paquete oficial usa otro nombre.
- ORYZA y AquaCrop deben validarse con los paquetes Linux exactos que descargaste.

## Proximos pasos

- Copiar los binarios Linux reales a las carpetas `vendor/bin`.
- Ejecutar `./scripts/build_all.sh`.
- Validar un caso minimo por modelo.
- Publicar imagenes en Docker Hub.
- Crear un pequeno set de regression tests con inputs livianos y permitidos por licencia.
