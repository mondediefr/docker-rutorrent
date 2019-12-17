FROM alpine:3.10 AS builder

ARG RTORRENT_VER=0.9.8
ARG LIBTORRENT_VER=0.13.8
ARG LIBZEN_VER=0.4.37
ARG LIBMEDIAINFO_VER=19.09
ARG GEOIP_VER=1.1.1

RUN apk add --no-progress --no-cache --upgrade \
    git \
    tar \
    wget \
    automake \
    autoconf \
    build-base \
    linux-headers \
    libtool \
    zlib-dev \
    cppunit-dev \
    cppunit \
    ncurses-dev \
    curl-dev \
    curl \
    libsigc++-dev \
    libnl3-dev \
    libnl3 \
    geoip-dev \
    geoip \
    php7-pear \
    php7-dev \
  && git clone https://github.com/mirror/xmlrpc-c.git /tmp/xmlrpc-c \
  && git clone -b "v${LIBTORRENT_VER}" https://github.com/rakshasa/libtorrent.git /tmp/libtorrent \
  && git clone -b "v${RTORRENT_VER}" https://github.com/rakshasa/rtorrent.git /tmp/rtorrent \
  && wget https://mediaarea.net/download/source/libzen/${LIBZEN_VER}/libzen_${LIBZEN_VER}.tar.bz2 -O /tmp/libzen.tar.gz \
  && wget https://mediaarea.net/download/source/libmediainfo/${LIBMEDIAINFO_VER}/libmediainfo_${LIBMEDIAINFO_VER}.tar.gz -O /tmp/libmediainfo.tar.gz \
  && wget https://mediaarea.net/download/source/mediainfo/${LIBMEDIAINFO_VER}/mediainfo_${LIBMEDIAINFO_VER}.tar.gz -O /tmp/mediainfo.tar.gz \
  && export BUILD_CORES=$(grep -c "processor" /proc/cpuinfo) \
  # Compile libzen
  && cd /tmp \
  && tar -xjf /tmp/libzen.tar.gz \
  && cd /tmp/ZenLib/Project/GNU/Library \
  && ./autogen.sh \
  && ./configure --prefix=/usr/local --enable-shared --disable-static \
  && make -j ${BUILD_CORES} \
  && make install \
  # Compile libmediainfo
  && cd /tmp \
  && tar -xzf libmediainfo.tar.gz \
  && cd /tmp/MediaInfoLib/Project/GNU/Library \
  && ./autogen.sh \
  && ./configure \
  && make -j ${BUILD_CORES} \
  && make install \
  # Compile mediainfo cli
  && cd /tmp \
  && tar -xzf mediainfo.tar.gz \
  && cd /tmp/MediaInfo/Project/GNU/CLI \
  && ./autogen.sh \
  && ./configure \
  && make -j ${BUILD_CORES} \
  && make install \
  && strip -s /usr/local/bin/mediainfo \
  # Compile xmlrpc-c
  && cd /tmp/xmlrpc-c/stable \
  && ./configure \
  && make -j ${BUILD_CORES} \
  && make install \
  # Compile libtorrent
  && cd /tmp/libtorrent \
  && ./autogen.sh \
  && ./configure --disable-debug --disable-instrumentation \
  && make -j ${BUILD_CORES} \
  && make install \
  # Compile rtorrent
  && cd /tmp/rtorrent \
  && ./autogen.sh \
  && ./configure --enable-ipv6 --disable-debug --with-xmlrpc-c \
  && make -j ${BUILD_CORES} \
  && make install \
  && strip -s /usr/local/bin/rtorrent \
  # Compile Geoip php module
  && pecl install geoip-${GEOIP_VER}

FROM alpine:3.10

LABEL description="rutorrent based on alpinelinux" \
      tags="latest" \
      maintainer="magicalex <magicalex@mondedie.fr>"

ARG FILEBOT=false
ARG FILEBOT_VER=4.8.5
ARG CHROMAPRINT_VER=1.4.3

ENV UID=991 \
    GID=991 \
    PORT_RTORRENT=45000 \
    DHT_RTORRENT=off \
    CHECK_PERM_DATA=true \
    FILEBOT_RENAME_METHOD=symlink \
    FILEBOT_LANG=fr \
    FILEBOT_CONFLICT=skip

COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /usr/local/lib /usr/local/lib
COPY --from=builder /usr/lib/php7/modules/geoip.so /usr/lib/php7/modules/geoip.so

RUN apk add --no-progress --no-cache --upgrade \
    libsigc++-dev \
    ncurses-dev \
    curl-dev \
    curl \
    git \
    wget \
    nginx \
    php7 \
    php7-fpm \
    php7-json \
    php7-opcache \
    php7-apcu \
    php7-mbstring \
    php7-ctype \
    php7-sockets \
    php7-phar \
    file \
    findutils \
    tar \
    gzip \
    zip \
    bzip2 \
    unrar \
    mktorrent \
    ffmpeg \
    s6 \
    su-exec \
    sox \
  # Install rutorrent
  && git clone https://github.com/Novik/ruTorrent.git /rutorrent/app \
  && git clone https://github.com/Phlooo/ruTorrent-MaterialDesign.git /rutorrent/app/plugins/theme/themes/materialdesign \
  && git clone https://github.com/Micdu70/geoip2-rutorrent /rutorrent/app/plugins/geoip2 \
  && git clone https://github.com/nelu/rutorrent-thirdparty-plugins.git /tmp/rutorrent-thirdparty-plugins \
  && cp -r /tmp/rutorrent-thirdparty-plugins/filemanager /rutorrent/app/plugins \
  && rm -rf /rutorrent/app/plugins/geoip \
  && rm -rf /rutorrent/app/plugins/_cloudflare \
  # Geoip module
  && cd /tmp \
  && wget https://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz \
  && wget https://geolite.maxmind.com/download/geoip/database/GeoLite2-Country.tar.gz \
  && tar -xzf GeoLite2-City.tar.gz \
  && tar -xzf GeoLite2-Country.tar.gz \
  && mv GeoLite2-*/*.mmdb /rutorrent/app/plugins/geoip2/database \
  && chmod +x /usr/lib/php7/modules/geoip.so \
  # Socket folder
  && mkdir -p /run/rtorrent /run/nginx /run/php \
  # Cleanup
  && rm -rf /tmp/*

RUN if [ "${FILEBOT}" == "true" ]; then \
  apk add --no-progress --no-cache --upgrade \
    openjdk11-jre \
    java-jna-native \
    xz \
  # Install filebot
  && mkdir /filebot \
  && cd /filebot \
  && wget https://get.filebot.net/filebot/FileBot_${FILEBOT_VER}/FileBot_${FILEBOT_VER}-portable.tar.xz -O /filebot/filebot.tar.xz \
  && tar -xJf filebot.tar.xz \
  && rm -rf filebot.tar.xz \
  && ln -sf /usr/local/lib/libzen.so.0.0.0 /filebot/lib/Linux-x86_64/libzen.so \
  && ln -sf /usr/local/lib/libmediainfo.so.0.0.0 /filebot/lib/Linux-x86_64/libmediainfo.so \
  # Install chromaprint acoustid
  && wget https://github.com/acoustid/chromaprint/releases/download/v${CHROMAPRINT_VER}/chromaprint-fpcalc-${CHROMAPRINT_VER}-linux-x86_64.tar.gz -O /tmp/chromaprint-fpcalc.tar.gz \
  && cd /tmp \
  && tar -xzf chromaprint-fpcalc.tar.gz \
  && mv chromaprint-fpcalc-${CHROMAPRINT_VER}-linux-x86_64/fpcalc /usr/local/bin \
  && rm -rf /tmp/chromaprint-fpcalc.tar.gz \
  && strip -s /usr/local/bin/fpcalc \
  && rm -rf /tmp/* \
  ; fi

COPY rootfs /
RUN chmod +x /usr/local/bin/startup
VOLUME /data /config
EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/startup"]
CMD ["/bin/s6-svscan", "/etc/s6.d"]
