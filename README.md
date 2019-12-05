# :warning: WORK IN PROGRESS NOT FUNCTIONAL :warning:

# mondedie/rtorrent-rutorrent

[![](https://img.shields.io/docker/cloud/build/mondedie/rtorrent-rutorrent)](https://hub.docker.com/r/mondedie/rtorrrent-rutorrent/builds)
[![](https://img.shields.io/docker/cloud/automated/mondedie/rtorrent-rutorrent)](https://hub.docker.com/r/mondedie/rtorrrent-rutorrent/builds)
[![](https://img.shields.io/docker/pulls/mondedie/rtorrent-rutorrent)](https://hub.docker.com/r/mondedie/rtorrrent-rutorrent)
[![](https://img.shields.io/docker/stars/mondedie/rtorrent-rutorrent)](https://hub.docker.com/r/mondedie/rtorrrent-rutorrent)

## Features

 * Based on Alpine Linux.
 * rTorrent and libtorrent are compiled from source.
 * Provides by default a solid configuration.
 * Filebot is included, and creates symlinks in /data/Media.
 * No **ROOT** process.
 * Persitance custom configuration for rutorrent and rtorrent.
 * Add your own plugins and themes

## Tag available

 * latest [(Dockerfile)](https://github.com/mondediefr/docker-rtorrent-rutorrent/blob/master/Dockerfile)
 * latest-filebot, filebot [(Dockerfile)](https://github.com/mondediefr/docker-rtorrent-rutorrent/blob/master/Dockerfile)

## BUILD IMAGE

### Build arguments

| Arguments | Description | Type | Default value |
| --------- | ----------- | ---- | ------------- |
| **RTORRENT_VER** | rtorrent version | *optional* | v0.9.8
| **LIBTORRENT_VER** | libtorrent version | *optional* | v0.13.8
| **FILEBOT** | Build with filebot feature | *optional* | NO
| **FILEBOT_VER** | Filebot version | *optional* | 4.7.9
| **CHROMAPRINT_VER** | Chromaprint version | *optional* | 1.4.3

### build

```sh
docker build -t mondedie/rtorrent-rtorrent \
  https://github.com/mondediefr/docker-rtorrent-rutorrent.git#master:rtorrent-rutorrent
```

### Build with arguments

```sh
docker build -t mondedie/rtorrent-rtorrent:filebot \
  --build-arg FILEBOT=YES \
  --build-arg RTORRENT_VER=v0.9.6 \
  --build-arg LIBTORRENT_VER=v0.13.6 \
  https://github.com/mondediefr/docker-rtorrent-rutorrent.git#master:rtorrent-rutorrent
```

## Configuration

### Environment variables

| Variable | Description | Type | Default value |
| -------- | ----------- | ---- | ------------- |
| **UID** | Choose uid for launch rtorrent | *optional* | 991
| **GID** | Choose gid for launch rtorrent | *optional* | 991
| **WEBROOT** | Webroot path for rutorrent | *optional* | /
| **PORT_RTORRENT** | Port of rtorrent | *optional* | 45000
| **DHT_RTORRENT** | DHT option in rtorrent.rc file | *optional* | off
| **DISABLE_PERM_DATA** | Don't check permission data in download directory | *optional* | false

### Environment variables with filebot

| Variable | Description | Type | Default value |
| -------- | ----------- | ---- | ------------- |
| **FILEBOT_RENAME_METHOD** | Method for rename media | *optional* | symlink
| **FILEBOT_RENAME_MOVIES** | Regex for rename movies | *optional* | "{n} ({y})"
| **FILEBOT_RENAME_MUSICS** | Regex for rename musics | *optional* | "{n}/{fn}"
| **FILEBOT_RENAME_SERIES** | Regex for rename series | *optional* | "{n}/Season {s.pad(2)}/{s00e00} - {t}"
| **FILEBOT_RENAME_ANIMES** | Regex for rename animes | *optional* | "{n}/{e.pad(3)} - {t}"
| **FILEBOT_LANG** | Set your language | *optional* | fr
| **FILEBOT_CONFLICT** | Conflict management | *optional* | skip

### Volumes

 * `/data` : Folder for download torrents
 * `/config` : Folder for rtorrent and rutorrent configuration

#### data folder tree

 * /data/.watch : Rtorrent watch directory
 * /data/.session : Rtorrent save statement here
 * /data/torrents : Rtorrent download torrent here
 * /data/Media : If filebot version, rtorrent create a symlink
 * /config/rtorrent : Path of .rtorrent.rc
 * /config/rutorrent/conf : Global configuration of rutorrent
 * /config/rutorrent/share : rutorrent user configuration and cache
 * /config/custom_plugins : Add your own plugins
 * /config/custom_themes : Add your own themes

### Ports

 * 8080
 * $PORT_RTORRENT (default : 45000)

## Usage

### Simple launch

```sh
docker run -dt -p 8080:8080 -p 45000:45000 mondedie/rtorrent-rutorrent
```

URI access : http://XX.XX.XX.XX:8080

### Advanced launch

Add custom plugin :

```sh
mkdir -p /docker/config/custom_plugins
cd /docker/config/custom_plugins
git clone https://github.com/Gyran/rutorrent-ratiocolor.git ./ratiocolor
```

Run container :

```sh
docker run -dt
  -p 9080:8080 \
  -p 6881:6881 \
  -p 6881:6881/udp \
  -e WEBROOT=/rutorrent \
  -e DHT_RTORRENT=on \
  -e PORT_RTORRENT=6881 \
  -e FILEBOT_RENAME_METHOD=move \
  -e FILEBOT_RENAME_SERIES="{n}/Season {s}/{n} - {s00e00} - {t}" \
  -e UID=1001 \
  -e GID=1001 \
  -v rutorrent-data-volume:/data \
  -v /docker/config:/config \
  mondedie/rtorrent-rutorrent:filebot
```

URI access : http://XX.XX.XX.XX:9080/rutorrent

## License

mondedie/rtorrent-rutorrent is released under the [MIT License](https://github.com/mondediefr/docker-rtorrent-rutorrent/blob/master/LICENSE).
