FROM alpine:3.13 AS builder

ARG TARGETPLATFORM

RUN apk add --no-progress \
    autoconf \
    automake \
    build-base \
    curl \
    curl-dev \
    cmake \
    cppunit-dev \
    cppunit \
    ffmpeg-dev \
    ffmpeg-libs \
    fftw-dev \
    git \
    libnl3 \
    libnl3-dev \
    libtool \
    linux-headers \
    openjdk8 \
    openjdk8-jre \
    zlib-dev \
  # Downloads projects
  && git clone https://github.com/borisbrodski/sevenzipjbinding.git /tmp/SevenZipJBinding \
  # Set BUILD_CORES
  && BUILD_CORES="$(grep -c processor /proc/cpuinfo)" \
  # Compile SevenZipJBinding
  && cd /tmp/SevenZipJBinding \
  && cmake . -DJAVA_JDK=/usr/lib/jvm/java-1.8-openjdk \
  && make -j "${BUILD_CORES}" \
  && case "${TARGETPLATFORM}" in \
    "linux/amd64") cp /tmp/SevenZipJBinding/Linux-amd64/lib7-Zip-JBinding.so /usr/local/lib;; \
    "linux/arm64") cp /tmp/SevenZipJBinding/Linux-aarch64/lib7-Zip-JBinding.so /usr/local/lib;; \
  esac \
  # Removes symbols that are not needed
  && find /usr/local/lib -name "*.so" -exec strip -s {} \;

FROM alpine:3.13

LABEL description="rutorrent based on alpinelinux" \
      maintainer="magicalex <magicalex@mondedie.fr>"

ARG TARGETPLATFORM
ARG FILEBOT=false
ARG FILEBOT_VER=4.9.4

ENV UID=991 \
    GID=991 \
    PORT_RTORRENT=45000 \
    DHT_RTORRENT=off \
    CHECK_PERM_DATA=true \
    FILEBOT_RENAME_METHOD=symlink \
    FILEBOT_LANG=fr \
    FILEBOT_CONFLICT=skip \
    HTTP_AUTH=false

COPY --from=builder /usr/local/lib /usr/local/lib

RUN apk add --no-progress --no-cache \
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
    php8 \
    php8-bcmath \
    php8-ctype \
    php8-curl \
    php8-fpm \
    php8-mbstring \
    php8-opcache \
    php8-pecl-apcu \
    php8-phar \
    php8-session \
    php8-sockets \
    php8-zip \
    rtorrent \
    s6 \
    sox \
    su-exec \
    unrar \
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
  apk add --no-progress --no-cache \
    chromaprint \
    openjdk11 \
    openjdk11-jre \
    zlib-dev \
  # Install filebot
  && mkdir /filebot \
  && cd /filebot \
  && wget "https://get.filebot.net/filebot/FileBot_${FILEBOT_VER}/FileBot_${FILEBOT_VER}-portable.tar.xz" -O /filebot/filebot.tar.xz \
  && tar -xJf filebot.tar.xz \
  && rm -rf filebot.tar.xz \
  # Fix filebot lib
  && case "${TARGETPLATFORM}" in \
    "linux/amd64") \
      ln -sf /usr/lib/libzen.so /filebot/lib/Linux-x86_64/libzen.so \
      && ln -sf /usr/lib/libmediainfo.so /filebot/lib/Linux-x86_64/libmediainfo.so \
      && ln -sf /usr/local/lib/lib7-Zip-JBinding.so /filebot/lib/Linux-x86_64/lib7-Zip-JBinding.so \
      && rm -rf /filebot/lib/FreeBSD-amd64 /filebot/lib/Linux-armv7l /filebot/lib/Linux-i686 /filebot/lib/Linux-aarch64;; \
    "linux/arm64") \
      ln -sf /lib/libz.so /filebot/lib/Linux-aarch64/libz.so \
      && ln -sf /usr/lib/libzen.so /filebot/lib/Linux-aarch64/libzen.so \
      && ln -sf /usr/lib/libmediainfo.so /filebot/lib/Linux-aarch64/libmediainfo.so \
      && rm -rf /filebot/lib/FreeBSD-amd64 /filebot/lib/Linux-armv7l /filebot/lib/Linux-x86_64 /filebot/lib/Linux-i686;; \
  esac; \
  fi

COPY rootfs /
RUN chmod 775 /usr/local/bin/*
VOLUME /data /config
EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/startup"]
CMD ["/bin/s6-svscan", "/etc/s6.d"]
