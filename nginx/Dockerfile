FROM nginx:latest

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpcre3-dev \
    zlib1g-dev \
    libssl-dev \
    mercurial \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN which hg

RUN hg clone http://hg.nginx.org/nginx /usr/src/nginx

RUN git clone "https://github.com/nginx-sticky-module/nginx-sticky-module-ng.git" /usr/src/nginx-sticky-module-ng

RUN cd /usr/src/nginx \
    && ./configure --with-compat --add-dynamic-module=/usr/src/nginx-sticky-module-ng \
    && make modules \
    && install -m 0755 objs/ngx_http_sticky_module.so /usr/lib/nginx/modules

COPY ../nginx.conf /etc/nginx/nginx.conf

RUN echo "load_module /usr/lib/nginx/modules/ngx_http_sticky_module.so;" >> /etc/nginx/nginx.conf

# חשיפת פורט 80
EXPOSE 80

# הפעלת Nginx
CMD ["nginx", "-g", "daemon off;"]
