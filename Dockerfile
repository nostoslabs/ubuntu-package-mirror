FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        apt-mirror \
        nginx-core \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create nginx user and group
RUN groupadd -r nginx && useradd -r -g nginx nginx

# apt-mirror expects these dirs to exist inside the volume
RUN mkdir -p /var/spool/apt-mirror/var \
    && mkdir -p /var/www/html \
    && mkdir -p /var/lib/nginx/body \
    && mkdir -p /var/lib/nginx/proxy \
    && mkdir -p /var/lib/nginx/fastcgi \
    && mkdir -p /var/lib/nginx/uwsgi \
    && mkdir -p /var/lib/nginx/scgi \
    && mkdir -p /run/nginx \
    && mkdir -p /var/log/nginx \
    && mkdir -p /var/cache/nginx \
    && chown -R nginx:nginx /var/lib/nginx /run/nginx /var/log/nginx /var/cache/nginx /var/www/html \
    && chmod 755 /var/lib/nginx /run/nginx /etc/apt \
    && sed -i 's|pid /run/nginx.pid;|pid /tmp/nginx.pid;|' /etc/nginx/nginx.conf \
    && sed -i 's|user www-data;|user nginx;|' /etc/nginx/nginx.conf \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log \
    && rm -f /etc/apt/mirror.list

COPY nginx.conf /etc/nginx/sites-available/default
COPY entrypoint.sh /usr/local/bin/entrypoint

RUN chmod +x /usr/local/bin/entrypoint

VOLUME ["/var/spool/apt-mirror"]

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/entrypoint"]
CMD ["serve"]
