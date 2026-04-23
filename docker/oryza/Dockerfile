FROM debian:bookworm-slim

ARG ORYZA_EXECUTABLE=oryza

ENV ORYZA_EXECUTABLE="${ORYZA_EXECUTABLE}"
ENV PATH="/opt/oryza/bin:${PATH}"

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       bash \
       ca-certificates \
       libgfortran5 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /work

COPY docker/oryza/vendor/bin/ /opt/oryza/bin/
COPY docker/oryza/entrypoint.sh /usr/local/bin/oryza-entrypoint

RUN chmod +x /usr/local/bin/oryza-entrypoint \
    && find /opt/oryza/bin -type f -exec chmod +x {} \;

ENTRYPOINT ["oryza-entrypoint"]

