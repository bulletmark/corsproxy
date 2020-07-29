#!/bin/bash
# Script to build docker images (for all supported architectures).
# M.Blakeney, Jul 2020.

export DOCKER_CLI_EXPERIMENTAL=enabled

name=$(basename $PWD)

if ! docker buildx use $name 2>/dev/null; then
    docker buildx create --name $name --use
fi

docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
exec docker buildx build \
    --push \
    --platform=linux/amd64 \
    --platform=linux/arm64 \
    --platform=linux/arm \
    -t bulletmark/corsproxy:latest . "$@"
