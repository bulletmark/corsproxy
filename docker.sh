#!/bin/bash
# Script to build docker image.
# M.Blakeney, Oct 2019.

ARM=""
if uname -m | grep -q arm; then
    ARM="-arm"
fi

export DOCKER_BUILDKIT=1
exec docker build -t bulletmark/corsproxy$ARM:latest . "$@"
