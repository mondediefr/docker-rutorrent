#!/usr/bin/env sh

# Login dockerhub
echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USERNAME}" --password-stdin

# build tag latest and filebot
# docker build --tag mondedie/rutorrent:latest .
# docker build --tag mondedie/rutorrent:filebot --build-arg FILEBOT=YES .

# push to dockerhub
docker push mondedie/rutorrent:latest
docker push mondedie/rutorrent:filebot
