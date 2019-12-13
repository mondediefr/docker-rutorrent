#!/usr/bin/env sh

# pull last docker image
docker pull mondedie/rutorrent:latest
docker pull mondedie/rutorrent:filebot

# build tag latest and filebot
docker build --cache-from mondedie/rutorrent:latest --tag mondedie/rutorrent:latest .
docker build --cache-from mondedie/rutorrent:filebot --tag mondedie/rutorrent:filebot --build-arg FILEBOT=YES .

# login dockerhub
echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USERNAME}" --password-stdin

# push to dockerhub
docker push mondedie/rutorrent:latest
docker push mondedie/rutorrent:filebot
