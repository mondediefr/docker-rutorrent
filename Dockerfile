FROM alpine:3.20 AS builder

ARG UNRAR_VER=7.0.9

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

FROM alpine:3.20

LABEL description="rutorrent based on alpinelinux" \
  maintainer="KDTheory <kdarmondev@gmail.com>"

ENV UID=991 \
  GID=991 \
  PORT_RTORRENT=45000 \
  MODE_DHT=off \
  PORT_DHT=6881 \
  PEER_EXCHANGE=no \
  DOWNLOAD_DIRECTORY=/data/downloads \
  CHECK_PERM_DATA=true \
  HTTP_AUTH=false

COPY --from=builder /usr/bin/unrar /usr/bin

RUN apk --update --no-cache add \
  7zip \
  bash \
  curl \
  curl-dev \
  ffmpeg \
  ffmpeg-dev \
  findutils \
  git \
  jq \
  libmediainfo \
  libmediainfo-dev \
  libzen \
  libzen-dev \
  mediainfo \
  mktorrent \
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
  s6 \
  sox \
  su-exec \
  unzip \
  # Récupération automatique de la dernière version stable de ruTorrent
  && RUTORRENT_VER=$(curl -s https://api.github.com/repos/Novik/ruTorrent/releases | \
  jq -r '[.[] | select(.prerelease == false)][0].tag_name' | sed 's/v//') \
  && echo "Dernière version stable de ruTorrent : ${RUTORRENT_VER}" \
  && curl -L "https://github.com/Novik/ruTorrent/archive/v${RUTORRENT_VER}.tar.gz" | tar xz \
  && mv "ruTorrent-${RUTORRENT_VER}" /rutorrent/app \
  && git clone https://github.com/Micdu70/geoip2-rutorrent.git /rutorrent/app/plugins/geoip2 \
  && git clone https://github.com/Micdu70/rutorrent-ratiocolor.git /rutorrent/app/plugins/ratiocolor \
  && rm -rf /rutorrent/app/plugins/geoip \
  && rm -rf /rutorrent/app/plugins/_cloudflare \
  && rm -rf /rutorrent/app/plugins/geoip2/.git \
  && rm -rf /rutorrent/app/plugins/ratiocolor/.git \
  && rm -rf /rutorrent/app/.git \
  # Socket folder
  && mkdir -p /run/rtorrent /run/nginx /run/php \
  # Cleanup
  && apk del --purge git

COPY rootfs /
RUN chmod 775 /usr/local/bin/*
VOLUME /data /config
EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/startup"]
CMD ["/bin/s6-svscan", "/etc/s6.d"]
