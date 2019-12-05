FROM alpine:3.10

ARG RTORRENT_VER=v0.9.8
ARG LIBTORRENT_VER=v0.13.8
ARG FILEBOT=NO
ARG FILEBOT_VER=4.7.9
ARG CHROMAPRINT_VER=1.4.3

ENV UID=991 \
    GID=991 \
    WEBROOT=/ \
    PORT_RTORRENT=45000 \
    DHT_RTORRENT=off \
    DISABLE_PERM_DATA=false \
    FILEBOT_RENAME_METHOD="symlink" \
    FILEBOT_RENAME_MOVIES="{n} ({y})" \
    FILEBOT_RENAME_SERIES="{n}/Season {s.pad(2)}/{s00e00} - {t}" \
    FILEBOT_RENAME_ANIMES="{n}/{e.pad(3)} - {t}" \
    FILEBOT_RENAME_MUSICS="{n}/{fn}" \
    FILEBOT_LANG="fr" \
    FILEBOT_CONFLICT=skip \
    filebot_version="${FILEBOT_VER}" \
    chromaprint_ver="${CHROMAPRINT_VER}"

LABEL description="rutorrent based on alpinelinux" \
      tags="latest" \
      maintainer="magicalex <magicalex@mondedie.fr>"

RUN apk --update-cache add git automake autoconf build-base linux-headers libtool zlib-dev libressl-dev \
    cppunit-dev cppunit libnl3 libnl3-dev ncurses-dev curl-dev curl wget libsigc++-dev nginx mediainfo \
    mktorrent ffmpeg gzip zip unrar s6 geoip geoip-dev su-exec nginx php7 php7-fpm php7-json php7-opcache \
    php7-apcu php7-mbstring php7-ctype php7-pear php7-dev php7-sockets php7-phar file findutils tar xz \
    libressl bzip2 \
  && git clone https://github.com/mirror/xmlrpc-c.git /tmp/xmlrpc-c \
  && git clone -b ${LIBTORRENT_VER} https://github.com/rakshasa/libtorrent.git /tmp/libtorrent \
  && git clone -b ${RTORRENT_VER} https://github.com/rakshasa/rtorrent.git /tmp/rtorrent \
  && export BUILD_CORES=$(grep -c "processor" /proc/cpuinfo) \
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
  # Install rutorrent
  && git clone https://github.com/Novik/ruTorrent.git /rutorrent/app \
  && git clone https://github.com/Phlooo/ruTorrent-MaterialDesign.git /rutorrent/app/plugins/theme/themes/materialdesign \
  && git clone https://github.com/Micdu70/geoip2-rutorrent /rutorrent/app/plugins/geoip2 \
  && rm -rf /var/www/html/rutorrent/plugins/geoip \
  # Socket folder
  && mkdir -p /run/rtorrent /run/nginx /run/php \
  # Cleanup
  && rm -rf /tmp/* /var/cache/apk/*

# RUN if [ "${FILEBOT}" == "YES" ]; then \
#   apk add --no-cache openjdk8-jre java-jna-native binutils wget nss \
#   && mkdir /filebot \
#   && cd /filebot \
#   && wget http://downloads.sourceforge.net/project/filebot/filebot/FileBot_${FILEBOT_VER}/FileBot_${FILEBOT_VER}-portable.tar.xz -O /filebot/filebot.tar.xz \
#   && tar xJf filebot.tar.xz \
#   && ln -sf /usr/local/lib/libzen.so.0.0.0 /filebot/lib/x86_64/libzen.so \
#   && ln -sf /usr/local/lib/libmediainfo.so.0.0.0 /filebot/lib/x86_64/libmediainfo.so \
#   && wget https://github.com/acoustid/chromaprint/releases/download/v${CHROMAPRINT_VER}/chromaprint-fpcalc-${CHROMAPRINT_VER}-linux-x86_64.tar.gz \
#   && tar xvf chromaprint-fpcalc-${CHROMAPRINT_VER}-linux-x86_64.tar.gz \
#   && mv chromaprint-fpcalc-${CHROMAPRINT_VER}-linux-x86_64/fpcalc /usr/local/bin \
#   && strip -s /usr/local/bin/fpcalc \
#   && apk del --no-cache binutils wget \
#   && rm -rf /tmp/* \
#             /filebot/FileBot_${FILEBOT_VER}-portable.tar.xz \
#             /filebot/chromaprint-fpcalc-${CHROMAPRINT_VER}-linux-x86_64.tar.gz\
#             /filebot/chromaprint-fpcalc-${CHROMAPRINT_VER}-linux-x86_64 \
#   ;fi

COPY rootfs /
VOLUME /data /config
EXPOSE 8080
RUN chmod +x /usr/local/bin/startup

ENTRYPOINT ["/usr/local/bin/startup"]
CMD ["/bin/s6-svscan", "/etc/s6.d"]
