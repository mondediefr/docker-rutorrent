FROM alpine:3.11 AS builder

ARG TARGETPLATFORM
ARG CHROMAPRINT_VER=1.4.3

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
    java-jna-native \
    libnl3 \
    libnl3-dev \
    libtool \
    linux-headers \
    openjdk8 \
    openjdk8-jre \
    zlib-dev \
  # Downloads projects
  && git clone https://github.com/borisbrodski/sevenzipjbinding.git /tmp/SevenZipJBinding \
  && wget "https://github.com/acoustid/chromaprint/releases/download/v${CHROMAPRINT_VER}/chromaprint-${CHROMAPRINT_VER}.tar.gz" -O /tmp/chromaprint-fpcalc.tar.gz \
  # Set BUILD_CORES
  && BUILD_CORES="$(grep -c processor /proc/cpuinfo)" \
  # Compile SevenZipJBinding
  && cd /tmp/SevenZipJBinding \
  && cmake . -DJAVA_JDK=/usr/lib/jvm/java-1.8-openjdk \
  && make -j "${BUILD_CORES}" \
  && case "${TARGETPLATFORM}" in \
    "linux/386") cp /tmp/SevenZipJBinding/Linux-i386/lib7-Zip-JBinding.so /usr/local/lib;; \
    "linux/amd64") cp /tmp/SevenZipJBinding/Linux-amd64/lib7-Zip-JBinding.so /usr/local/lib;; \
    "linux/arm/v7") cp /tmp/SevenZipJBinding/Linux-arm/lib7-Zip-JBinding.so /usr/local/lib;; \
    "linux/arm64") cp /tmp/SevenZipJBinding/Linux-aarch64/lib7-Zip-JBinding.so /usr/local/lib;; \
  esac \
  # Compile chromaprint
  && cd /tmp \
  && tar -xzf chromaprint-fpcalc.tar.gz \
  && cd "chromaprint-v${CHROMAPRINT_VER}" \
  && cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_TOOLS=ON . \
  && make -j "${BUILD_CORES}" \
  && make install \
  && strip -s /usr/local/bin/fpcalc \
  # Removes symbols that are not needed
  && find /usr/local/lib -name "*.so" -exec strip -s {} \;

FROM alpine:3.11

LABEL description="rutorrent based on alpinelinux" \
      maintainer="magicalex <magicalex@mondedie.fr>"

ARG TARGETPLATFORM
ARG FILEBOT=false
ARG FILEBOT_VER=4.9.1

ENV UID=991 \
    GID=991 \
    PORT_RTORRENT=45000 \
    DHT_RTORRENT=off \
    CHECK_PERM_DATA=true \
    FILEBOT_RENAME_METHOD=symlink \
    FILEBOT_LANG=fr \
    FILEBOT_CONFLICT=skip \
    HTTP_AUTH=false

COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /usr/local/lib /usr/local/lib

RUN apk add --no-progress --no-cache \
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
    php7 \
    php7-apcu \
    php7-bcmath \
    php7-ctype \
    php7-fpm \
    php7-json \
    php7-mbstring \
    php7-opcache \
    php7-phar \
    php7-sockets \
    php7-zip \
    rtorrent \
    s6 \
    sox \
    su-exec \
    unrar \
    zip \
  # Install rutorrent
  && git clone https://github.com/Novik/ruTorrent.git /rutorrent/app \
  && git clone https://github.com/Phlooo/ruTorrent-MaterialDesign.git /rutorrent/app/plugins/theme/themes/materialdesign \
  && git clone https://github.com/nelu/rutorrent-thirdparty-plugins.git /tmp/rutorrent-thirdparty-plugins \
  && git clone https://github.com/Micdu70/geoip2-rutorrent.git /rutorrent/app/plugins/geoip2 \
  && cp -r /tmp/rutorrent-thirdparty-plugins/filemanager /rutorrent/app/plugins \
  && rm -rf /rutorrent/app/plugins/geoip \
  && rm -rf /rutorrent/app/plugins/_cloudflare \
  && rm -rf /rutorrent/app/plugins/theme/themes/materialdesign/.git \
  && rm -rf /rutorrent/app/plugins/geoip2/.git \
  && rm -rf /rutorrent/app/.git \
  && rm -rf /tmp/rutorrent-thirdparty-plugins \
  # Socket folder
  && mkdir -p /run/rtorrent /run/nginx /run/php \
  # Cleanup
  && apk del --purge git

RUN if [ "${FILEBOT}" = true ]; then \
  apk add --no-progress --no-cache \
    java-jna-native \
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
    "linux/386") \
      ln -sf /usr/lib/libzen.so /filebot/lib/Linux-i686/libzen.so \
      && ln -sf /usr/lib/libmediainfo.so /filebot/lib/Linux-i686/libmediainfo.so \
      && ln -sf /usr/lib/libjnidispatch.so /filebot/lib/Linux-i686/libjnidispatch.so \
      && ln -sf /usr/local/lib/lib7-Zip-JBinding.so /filebot/lib/Linux-i686/lib7-Zip-JBinding.so \
      && rm -rf /filebot/lib/FreeBSD-amd64 /filebot/lib/Linux-armv7l /filebot/lib/Linux-x86_64 /filebot/lib/Linux-aarch64;; \
    "linux/amd64") \
      ln -sf /usr/lib/libzen.so /filebot/lib/Linux-x86_64/libzen.so \
      && ln -sf /usr/lib/libmediainfo.so /filebot/lib/Linux-x86_64/libmediainfo.so \
      && ln -sf /usr/lib/libjnidispatch.so /filebot/lib/Linux-x86_64/libjnidispatch.so \
      && ln -sf /usr/local/lib/lib7-Zip-JBinding.so /filebot/lib/Linux-x86_64/lib7-Zip-JBinding.so \
      && rm -rf /filebot/lib/FreeBSD-amd64 /filebot/lib/Linux-armv7l /filebot/lib/Linux-i686 /filebot/lib/Linux-aarch64;; \
    "linux/arm/v7") \
      ln -sf /usr/lib/libzen.so /filebot/lib/Linux-armv7l/libzen.so \
      && ln -sf /usr/lib/libmediainfo.so /filebot/lib/Linux-armv7l/libmediainfo.so \
      && ln -sf /usr/lib/libjnidispatch.so /filebot/lib/Linux-armv7l/libjnidispatch.so \
      && ln -sf /usr/local/lib/lib7-Zip-JBinding.so /filebot/lib/Linux-armv7l/lib7-Zip-JBinding.so \
      && ln -sf /lib/libz.so /filebot/lib/Linux-armv7l/libz.so \
      && rm -rf /filebot/lib/FreeBSD-amd64 /filebot/lib/Linux-x86_64 /filebot/lib/Linux-i686 /filebot/lib/Linux-aarch64;; \
    "linux/arm64") \
      ln -sf /usr/lib/libjnidispatch.so /filebot/lib/Linux-aarch64/libjnidispatch.so \
      && rm -rf /filebot/lib/FreeBSD-amd64 /filebot/lib/Linux-armv7l /filebot/lib/Linux-x86_64 /filebot/lib/Linux-i686;; \
  esac; \
  fi

COPY rootfs /
RUN chmod 775 /usr/local/bin/*
VOLUME /data /config
EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/startup"]
CMD ["/bin/s6-svscan", "/etc/s6.d"]
