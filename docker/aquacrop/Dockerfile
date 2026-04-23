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

COPY docker/aquacrop/vendor/bin/ /opt/aquacrop/bin/
COPY docker/aquacrop/entrypoint.sh /usr/local/bin/aquacrop-entrypoint

RUN chmod +x /usr/local/bin/aquacrop-entrypoint \
    && find /opt/aquacrop/bin -type f -exec chmod +x {} \;

ENTRYPOINT ["aquacrop-entrypoint"]

