FROM debian:bookworm-slim

ARG DSSAT_EXECUTABLE=dscsm048

ENV DSSAT_EXECUTABLE="${DSSAT_EXECUTABLE}"
ENV PATH="/opt/dssat/bin:${PATH}"

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       bash \
       ca-certificates \
       libgfortran5 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /work

COPY docker/dssat/vendor/bin/ /opt/dssat/bin/
COPY docker/dssat/entrypoint.sh /usr/local/bin/dssat-entrypoint

RUN chmod +x /usr/local/bin/dssat-entrypoint \
    && find /opt/dssat/bin -type f -exec chmod +x {} \;

ENTRYPOINT ["dssat-entrypoint"]

