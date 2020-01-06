# Use manisfest-tool for multi-arch

```sh
cd /manifest
wget https://github.com/estesp/manifest-tool/releases/download/v1.0.0/manifest-tool-linux-amd64
mv manifest-tool-linux-amd64 manifest-tool
chmod +x manifest-tool
```

manifest-tool push from-spec latest.yml
manifest-tool push from-spec filebot.yml

```yml
image: mondedie/rutorrent:latest
manifests:
  -
    image: mondedie/rutorrent:amd64-latest
    platform:
      architecture: amd64
      os: linux
  -
    image: mondedie/rutorrent:arm64-latest
    platform:
      architecture: arm64
      os: linux
```

```yml
image: mondedie/rutorrent:filebot
manifests:
  -
    image: mondedie/rutorrent:amd64-filebot
    plateform:
      architecture: amd64
      os: linux
  -
    image: mondedie/rutorrent:arm64-filebot
    plateform:
      architecture: arm64
      os: linux
```
