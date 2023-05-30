#!/bin/bash
# Script to build docker images (for all supported architectures).
# M.Blakeney, Jul 2020.

# Ensure packages are installed
if ! pacman -Q docker docker-buildx >/dev/null; then
    exit $?
fi

if ! docker ps >/dev/null; then
    exit $?
fi

name="$(basename $PWD)"

docker buildx rm $name 2>/dev/null
docker buildx create --name $name --use

docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
exec docker buildx build \
    --push \
    --platform=linux/amd64 \
    --platform=linux/arm64 \
    --platform=linux/arm \
    -t bulletmark/corsproxy:latest . "$@"
