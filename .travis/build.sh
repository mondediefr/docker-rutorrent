#!/usr/bin/env sh

# Login
#docker login

# build latest tag
docker build --tag mondedie/rutorrent:latest .
# build filebot tag
docker build --tag mondedie/rutorrent:filebot --build-arg FILEBOT=YES .

# push to dockerhub
docker push mondedie/rutorrent:latest
docker push mondedie/rutorrent:filebot
