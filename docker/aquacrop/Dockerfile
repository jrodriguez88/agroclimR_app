FROM debian:bookworm-slim AS builder

ARG AQUACROP_REPO=https://github.com/KUL-RSDA/AquaCrop.git
ARG AQUACROP_REF=v7.3_typofix

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       ca-certificates \
       gfortran \
       git \
       make \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# AquaCrop v7+ is open-source Fortran. The upstream build is: cd src && make.
RUN git clone --depth 1 --branch "${AQUACROP_REF}" "${AQUACROP_REPO}" AquaCrop \
    && make -C AquaCrop/src \
    && mkdir -p /opt/aquacrop/bin \
    && cp AquaCrop/src/aquacrop /opt/aquacrop/bin/aquacrop

FROM debian:bookworm-slim

ARG AQUACROP_EXECUTABLE=aquacrop

ENV AQUACROP_EXECUTABLE="${AQUACROP_EXECUTABLE}"
ENV PATH="/opt/aquacrop/bin:${PATH}"

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       bash \
       ca-certificates \
       libgfortran5 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /work

COPY --from=builder /opt/aquacrop/ /opt/aquacrop/
COPY docker/aquacrop/vendor/bin/ /opt/aquacrop/bin/
COPY docker/aquacrop/entrypoint.sh /usr/local/bin/aquacrop-entrypoint

RUN chmod +x /usr/local/bin/aquacrop-entrypoint \
    && find /opt/aquacrop/bin -type f -exec chmod +x {} \;

ENTRYPOINT ["aquacrop-entrypoint"]
