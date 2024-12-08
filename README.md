# mondedie/rutorrent

[![](https://github.com/mondediefr/docker-rutorrent/workflows/build/badge.svg)](https://github.com/mondediefr/docker-rutorrent/actions)
[![](https://img.shields.io/docker/pulls/mondedie/rutorrent)](https://hub.docker.com/r/mondedie/rutorrent)
[![](https://img.shields.io/docker/stars/mondedie/rutorrent)](https://hub.docker.com/r/mondedie/rutorrent)

## Features

 - Platform image: `linux/amd64`, `linux/arm64`
 - Based on Alpine Linux 3.21
 - php 8.2
 - Provides by default a solid configuration
 - No root process
 - Persitance custom configuration for rutorrent and rtorrent
 - Add your own rutorrent plugins and themes
 - Filebot is included, and creates symlinks in `/data/media` (choose filebot tag)

## Tag available

 - latest [(Dockerfile)](https://github.com/mondediefr/docker-rutorrent/blob/master/Dockerfile)
 - filebot [(Dockerfile)](https://github.com/mondediefr/docker-rutorrent/blob/master/Dockerfile)

## Build image

### Build arguments

| Argument | Description | Type | Default value |
| -------- | ----------- | ---- | ------------- |
| **FILEBOT** | Build with filebot | *optional* | false
| **FILEBOT_VER** | Filebot version | *optional* | 5.1.6
| **RUTORRENT_VER** | ruTorrent version | *optional* | 5.1.2

### build

```sh
docker build --tag mondedie/rutorrent:latest https://github.com/mondediefr/docker-rutorrent.git
```

### Build with arguments

```sh
docker build --tag mondedie/rutorrent:filebot --build-arg FILEBOT=true https://github.com/mondediefr/docker-rutorrent.git
```

## Configuration

### Environment variables

| Variable | Description | Type | Default value |
| -------- | ----------- | ---- | ------------- |
| **UID** | Choose uid for launch rtorrent | *optional* | 991
| **GID** | Choose gid for launch rtorrent | *optional* | 991
| **PORT_RTORRENT** | Port of rtorrent | *optional* | 45000
| **MODE_DHT** | DHT mode in rtorrent.rc file (disable,off,on) | *optional* | off
| **PORT_DHT** | UDP port to use for DHT | *optional* | 6881
| **PEER_EXCHANGE** | Enable peer exchange (yes,no) | *optional* | no
| **DOWNLOAD_DIRECTORY** | Torrent download directory | *optional* | /data/downloads
| **CHECK_PERM_DATA** | Check permissions in the data directory | *optional* | true
| **HTTP_AUTH** | Enable HTTP authentication | *optional* | false

### Environment variables with filebot

| Variable | Description | Type | Default value |
| -------- | ----------- | ---- | ------------- |
| **FILEBOT_LICENSE** | License file path | **required** | none
| **FILEBOT_RENAME_METHOD** | Method for rename media | *optional* | symlink
| **FILEBOT_LANG** | Set your language | *optional* | fr
| **FILEBOT_CONFLICT** | Conflict management | *optional* | skip

### Volumes

 - `/data` : folder for download torrents
 - `/config` : folder for rtorrent and rutorrent configuration

#### Data folder tree

 - `/data/.watch` : rtorrent watch directory
 - `/data/.session` : rtorrent save statement here
 - `/data/downloads` : rtorrent download torrent here
 - `/data/media` : organize your media and create a symlink with filebot
 - `/config/rtorrent` : path of .rtorrent.rc
 - `/config/rutorrent/conf` : global configuration of rutorrent
 - `/config/rutorrent/share` : rutorrent user configuration and cache
 - `/config/custom_plugins` : add your own plugins
 - `/config/custom_themes` : add your own themes
 - `/config/filebot` : add your License file in this folder
 - `/config/filebot/args_amc.txt` : configuration of fn:amc script of filebot
 - `/config/filebot/postdl` : modify postdl script, example [here](https://github.com/mondediefr/docker-rutorrent/blob/master/rootfs/usr/local/bin/postdl)

### Ports

 - 8080
 - PORT_RTORRENT (default: 45000)

## Usage

### Simple launch

```sh
docker run --name rutorrent -dt \
  -e UID=1000 \
  -e GID=1000 \
  -p 8080:8080 \
  -p 45000:45000 \
  -v /mnt/docker/rutorrent/config:/config \
  -v /mnt/docker/rutorrent/data:/data \
  mondedie/rutorrent:latest
```

URL: http://xx.xx.xx.xx:8080

### Advanced launch

Add custom plugin :

```sh
mkdir -p /mnt/docker/rutorrent/config/custom_plugins
git clone https://github.com/Gyran/rutorrent-ratiocolor.git /mnt/docker/rutorrent/config/custom_plugins/ratiocolor
```

Add custom theme :

Donwload a theme for example in this repository https://github.com/artyuum/3rd-party-ruTorrent-Themes.git  
And copy the folder in `/mnt/docker/rutorrent/config/custom_themes`

Run container :

```sh
docker run --name rutorrent -dt \
  -e UID=1000 \
  -e GID=1000 \
  -e DHT_RTORRENT=on \
  -e PORT_RTORRENT=6881 \
  -e FILEBOT_LICENSE=/config/filebot/FileBot_License_XXXXXXXXX.psm \
  -e FILEBOT_RENAME_METHOD=move \
  -p 9080:8080 \
  -p 6881:6881 \
  -p 6881:6881/udp \
  -v /mnt/docker/rutorrent/config:/config \
  -v /mnt/docker/rutorrent/data:/data \
  mondedie/rutorrent:filebot
```

URL: http://xx.xx.xx.xx:9080

### Add HTTP authentication

```sh
docker run --name rutorrent -dt \
  -e UID=1000 \
  -e GID=1000 \
  -e PORT_RTORRENT=46000 \
  -e HTTP_AUTH=true \
  -p 8080:8080 \
  -p 46000:46000 \
  -v /mnt/docker/rutorrent/config:/config \
  -v /mnt/docker/rutorrent/data:/data \
  mondedie/rutorrent:latest
```

Generate your password:

```sh
docker exec -it rutorrent gen-http-passwd
Username: torrent
Password:
Verifying - Password:
Password was generated for the http user: torrent
```

URL: http://xx.xx.xx.xx:8080

## License

Docker image [mondedie/rutorrent](https://hub.docker.com/r/mondedie/rutorrent) is released under [MIT License](https://github.com/mondediefr/docker-rutorrent/blob/master/LICENSE).
