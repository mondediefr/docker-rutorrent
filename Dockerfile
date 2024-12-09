ARG MKTORRENT_VERSION=v1.1
ARG DUMP_TORRENT_VERSION=302ac444a20442edb4aeabef65b264a85ab88ce9

# Create src image to retreive source files
FROM alpine:3.21 AS src
RUN apk --update --no-cache add curl git tar sed tree xz
WORKDIR /src

# Retreive source files for mktorrent
FROM src AS src-mktorrent
RUN git init . && git remote add origin "https://github.com/pobrn/mktorrent.git"
ARG MKTORRENT_VERSION
RUN git fetch origin "${MKTORRENT_VERSION}" && git checkout -q FETCH_HEAD

# Retreive source files for dumptorrent. Repair build for alpine Linux.
FROM src AS src-dump-torrent
RUN git init . && git remote add origin "https://github.com/TheGoblinHero/dumptorrent.git"
ARG DUMP_TORRENT_VERSION
RUN git fetch origin "${DUMP_TORRENT_VERSION}" && git checkout -q FETCH_HEAD
RUN sed -i '1i #include <sys/time.h>' scrapec.c
RUN rm -rf .git*

FROM alpine:3.21 AS builder

ENV DIST_PATH="/dist"

RUN apk --update --no-cache add \
    autoconf \
    automake \
    binutils \
    build-base \
    cmake \
    cppunit-dev \
    curl-dev \
    libtool \
    linux-headers \
    tree \
    zlib-dev

# Build and install mktorrent with pthreads
WORKDIR /usr/local/src/mktorrent
COPY --from=src-mktorrent /src .
RUN echo "CC = gcc" >> Makefile	
RUN echo "CFLAGS = -w -flto -O3" >> Makefile
RUN echo "USE_PTHREADS = 1" >> Makefile
RUN echo "USE_OPENSSL = 1" >> Makefile
RUN make -j$(nproc)
RUN make install -j$(nproc)
RUN make DESTDIR=${DIST_PATH} install -j$(nproc)
RUN tree ${DIST_PATH}

# Build and install dump torrent for ruTorrent plugin
WORKDIR /usr/local/src/dump-torrent
COPY --from=src-dump-torrent /src .
RUN make dumptorrent -j$(nproc)
RUN cp dumptorrent ${DIST_PATH}/usr/local/bin
RUN tree ${DIST_PATH}

FROM alpine:3.21

LABEL description="rutorrent based on alpinelinux" \
      maintainer="magicalex <magicalex@mondedie.fr>"

ARG FILEBOT=false
ARG FILEBOT_VER=5.1.6
ARG RUTORRENT_VER=5.1.2

ENV UID=991 \
    GID=991 \
    PORT_RTORRENT=45000 \
    MODE_DHT=off \
    PORT_DHT=6881 \
    PEER_EXCHANGE=no \
    DOWNLOAD_DIRECTORY=/data/downloads \
    CHECK_PERM_DATA=true \
    FILEBOT_RENAME_METHOD=symlink \
    FILEBOT_LANG=fr \
    FILEBOT_CONFLICT=skip \
    HTTP_AUTH=false

COPY --from=builder /dist /

# unrar package is not available since alpine 3.15
RUN echo "@314 http://dl-cdn.alpinelinux.org/alpine/v3.14/main" >> /etc/apk/repositories \
  && apk --update --no-cache add unrar@314

RUN echo "@320 http://dl-cdn.alpinelinux.org/alpine/v3.20/main" >> /etc/apk/repositories \
  && apk --update --no-cache add s6@320

RUN apk --update --no-cache add \
    7zip \
    bash \
    curl \
    curl-dev \
    ffmpeg \
    ffmpeg-dev \
    findutils \
    git \
    libmediainfo \
    libmediainfo-dev \
    libzen \
    libzen-dev \
    mediainfo \
    nginx \
    openssl \
    php82 \
    php82-bcmath \
    php82-ctype \
    php82-curl \
    php82-dom \
    php82-fpm \
    php82-mbstring \
    php82-opcache \
    php82-openssl \
    php82-pecl-apcu \
    php82-phar \
    php82-session \
    php82-sockets \
    php82-xml \
    php82-zip \
    rtorrent \
    sox \
    su-exec \
    unzip \
  # Install rutorrent
  && git clone -b v${RUTORRENT_VER} --recurse-submodules https://github.com/Novik/ruTorrent.git /rutorrent/app \
  && git clone https://github.com/Micdu70/geoip2-rutorrent.git /rutorrent/app/plugins/geoip2 \
  && git clone https://github.com/Micdu70/rutorrent-ratiocolor.git /rutorrent/app/plugins/ratiocolor \
  && rm -rf /rutorrent/app/plugins/geoip \
  && rm -rf /rutorrent/app/plugins/_cloudflare \
  && rm -rf /rutorrent/app/plugins/geoip2/.git \
  && rm -rf /rutorrent/app/plugins/ratiocolor/.git \
  && rm -rf /rutorrent/app/.git \
  # Socket folder
  && mkdir -p /run/rtorrent /run/nginx /run/php

RUN if [ "${FILEBOT}" = true ]; then \
  apk --update --no-cache add \
    chromaprint \
    openjdk17-jre-headless \
  # Install filebot
  && mkdir /filebot \
  && cd /filebot \
  && wget "https://get.filebot.net/filebot/FileBot_${FILEBOT_VER}/FileBot_${FILEBOT_VER}-portable.tar.xz" -O /filebot/filebot.tar.xz \
  && tar -xJf filebot.tar.xz \
  && rm -rf filebot.tar.xz \
  && sed -i 's/-Dapplication.deployment=tar/-Dapplication.deployment=docker/g' /filebot/filebot.sh \
  && find /filebot/lib -type f -not -name libjnidispatch.so -delete; \
  fi

COPY rootfs /
RUN chmod 775 /usr/local/bin/*
VOLUME /data /config
EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/startup"]
CMD ["/bin/s6-svscan", "/etc/s6.d"]
