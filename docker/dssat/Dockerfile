FROM debian:bookworm-slim AS builder

ARG DSSAT_REPO=https://github.com/DSSAT/dssat-csm-os.git
ARG DSSAT_REF=v4.8.5.0
ARG DSSAT_EXECUTABLE=dscsm048
ARG DSSAT_BUILD_TYPE=RELEASE

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       ca-certificates \
       cmake \
       gfortran \
       git \
       make \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# DSSAT follows an out-of-source CMake build: mkdir build, cmake .., make.
RUN git clone --depth 1 --branch "${DSSAT_REF}" "${DSSAT_REPO}" dssat-csm-os \
    && cmake -S dssat-csm-os -B dssat-csm-os/build -DCMAKE_BUILD_TYPE="${DSSAT_BUILD_TYPE}" \
    && cmake --build dssat-csm-os/build --parallel \
    && mkdir -p /opt/dssat/bin /opt/dssat/data \
    && cp "dssat-csm-os/build/bin/${DSSAT_EXECUTABLE}" /opt/dssat/bin/ \
    && cp -r dssat-csm-os/Data/. /opt/dssat/data/

FROM debian:bookworm-slim

ARG DSSAT_EXECUTABLE=dscsm048

ENV DSSAT_EXECUTABLE="${DSSAT_EXECUTABLE}"
ENV DSSAT_HOME=/opt/dssat
ENV DSSAT_DATA=/opt/dssat/data
ENV PATH="/opt/dssat/bin:${PATH}"

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       bash \
       ca-certificates \
       libgfortran5 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /work

COPY --from=builder /opt/dssat/ /opt/dssat/
COPY docker/dssat/vendor/bin/ /opt/dssat/bin/
COPY docker/dssat/entrypoint.sh /usr/local/bin/dssat-entrypoint

RUN chmod +x /usr/local/bin/dssat-entrypoint \
    && find /opt/dssat/bin -type f -exec chmod +x {} \;

ENTRYPOINT ["dssat-entrypoint"]
