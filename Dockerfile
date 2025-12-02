FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        apt-mirror \
        nginx-core \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# apt-mirror expects these dirs to exist inside the volume
RUN mkdir -p /var/spool/apt-mirror/var \
    && mkdir -p /var/www/html \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

COPY nginx.conf /etc/nginx/sites-available/default
COPY entrypoint.sh /usr/local/bin/entrypoint

RUN chmod +x /usr/local/bin/entrypoint

VOLUME ["/var/spool/apt-mirror"]

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/entrypoint"]
CMD ["serve"]
