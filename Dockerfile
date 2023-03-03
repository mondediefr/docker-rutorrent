FROM alpine:3.17 AS builder

ARG UNRAR_VER=6.2.6

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
    zlib-dev \
  # Install unrar from source
  && cd /tmp \
  && wget https://www.rarlab.com/rar/unrarsrc-${UNRAR_VER}.tar.gz -O /tmp/unrar.tar.gz \
  && tar -xzf /tmp/unrar.tar.gz \
  && cd unrar \
  && make -f makefile \
  && install -Dm 755 unrar /usr/bin/unrar

FROM alpine:3.17

LABEL description="rutorrent based on alpinelinux" \
      maintainer="magicalex <magicalex@mondedie.fr>"

ARG TARGETPLATFORM
ARG FILEBOT=false
ARG FILEBOT_VER=4.9.6

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

COPY --from=builder /usr/bin/unrar /usr/bin

RUN apk --update --no-cache add \
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
    mktorrent \
    nginx \
    openssl \
    p7zip \
    php81 \
    php81-bcmath \
    php81-ctype \
    php81-curl \
    php81-fpm \
    php81-mbstring \
    php81-opcache \
    php81-openssl \
    php81-pecl-apcu \
    php81-phar \
    php81-session \
    php81-sockets \
    php81-xml \
    php81-zip \
    rtorrent \
    s6 \
    sox \
    su-exec \
    unzip \
  # Install rutorrent
  && git clone --recurse-submodules https://github.com/Novik/ruTorrent.git /rutorrent/app \
  && git clone https://github.com/nelu/rutorrent-filemanager.git /tmp/filemanager \
  && git clone https://github.com/Micdu70/geoip2-rutorrent.git /rutorrent/app/plugins/geoip2 \
  && cp -r /tmp/filemanager /rutorrent/app/plugins \
  && rm -rf /rutorrent/app/plugins/geoip \
  && rm -rf /rutorrent/app/plugins/_cloudflare \
  && rm -rf /rutorrent/app/plugins/geoip2/.git \
  && rm -rf /rutorrent/app/.git \
  && rm -rf /tmp/filemanager \
  # Socket folder
  && mkdir -p /run/rtorrent /run/nginx /run/php \
  # Cleanup
  && apk del --purge git

RUN if [ "${FILEBOT}" = true ]; then \
  apk --update --no-cache add \
    chromaprint \
    openjdk17 \
    openjdk17-jre \
    zlib-dev \
  # Install filebot
  && mkdir /filebot \
  && cd /filebot \
  && wget "https://get.filebot.net/filebot/FileBot_${FILEBOT_VER}/FileBot_${FILEBOT_VER}-portable.tar.xz" -O /filebot/filebot.tar.xz \
  && tar -xJf filebot.tar.xz \
  && rm -rf filebot.tar.xz \
  && sed -i 's/-Dapplication.deployment=tar/-Dapplication.deployment=docker/g' /filebot/filebot.sh \
  # Fix filebot lib
  && case "${TARGETPLATFORM}" in \
    "linux/amd64") \
      rm -rf /filebot/lib/FreeBSD-amd64 /filebot/lib/Linux-aarch64 /filebot/lib/Linux-armv7l \
      && rm -rf /filebot/lib/Linux-x86_64/libzen.so /filebot/lib/Linux-x86_64/libmediainfo.so;; \
    "linux/arm64") \
      rm -rf /filebot/lib/FreeBSD-amd64 /filebot/lib/Linux-armv7l /filebot/lib/Linux-x86_64 \
      && rm -rf /filebot/lib/Linux-aarch64/libzen.so /filebot/lib/Linux-aarch64/libmediainfo.so;; \
  esac; \
  fi

COPY rootfs /
RUN chmod 775 /usr/local/bin/*
VOLUME /data /config
EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/startup"]
CMD ["/bin/s6-svscan", "/etc/s6.d"]
