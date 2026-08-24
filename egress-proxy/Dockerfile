# nginx does not support the HTTP CONNECT method out of the box, so we build
# it from source with ngx_http_proxy_connect_module to get a whitelisting
# forward proxy for HTTPS (CONNECT) traffic.
FROM debian:bookworm-slim AS builder

ARG NGINX_VERSION=1.27.1
# Pinned commit of chobits/ngx_http_proxy_connect_module (master, 2024-08-18).
ARG PROXY_CONNECT_REF=4f0b6c2297862148c59a0d585d6c46ccb7e58a39

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpcre3-dev \
    zlib1g-dev \
    libssl-dev \
    ca-certificates \
    curl \
    patch \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src
RUN curl -fsSL "https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" -o nginx.tar.gz \
    && tar -xzf nginx.tar.gz \
    && curl -fsSL "https://github.com/chobits/ngx_http_proxy_connect_module/archive/${PROXY_CONNECT_REF}.tar.gz" -o proxy_connect.tar.gz \
    && tar -xzf proxy_connect.tar.gz

WORKDIR /usr/src/nginx-1.27.1
RUN patch -p1 < "/usr/src/ngx_http_proxy_connect_module-${PROXY_CONNECT_REF}/patch/proxy_connect_rewrite_102101.patch" \
    && ./configure \
        --prefix=/etc/nginx \
        --sbin-path=/usr/sbin/nginx \
        --conf-path=/etc/nginx/nginx.conf \
        --pid-path=/var/run/nginx.pid \
        --error-log-path=/var/log/nginx/error.log \
        --http-log-path=/var/log/nginx/access.log \
        --add-module="/usr/src/ngx_http_proxy_connect_module-${PROXY_CONNECT_REF}" \
    && make -j"$(nproc)" \
    && make install

# Turn the plain domain list in allowed-domains.conf into the nginx map
# entries $connect_allowed needs (see nginx.conf).
FROM debian:bookworm-slim AS domainmapgen

WORKDIR /work
COPY generate-allowed-domains-map.sh allowed-domains.conf ./
RUN mkdir -p /out && ./generate-allowed-domains-map.sh allowed-domains.conf /out/allowed-domains-map.conf

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    libpcre3 \
    zlib1g \
    libssl3 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /var/log/nginx /var/cache/nginx

COPY --from=builder /usr/sbin/nginx /usr/sbin/nginx
COPY --from=domainmapgen /out/allowed-domains-map.conf /etc/nginx/allowed-domains-map.conf
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 8080
# SIGTERM = nginx "fast shutdown" (close all connections immediately).
# SIGQUIT ("graceful") would wait for long-lived proxy_connect tunnels
# (Slack Socket Mode, Discord gateway, ...) to end on their own, which they
# never do, so the container would just hang until Docker force-kills it.
STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]
