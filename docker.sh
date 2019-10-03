#!/bin/bash
# Script to build docker image.
# M.Blakeney, Oct 2019.

usage() {
    echo "Usage: $(basename $0) [-options]"
    echo "Options:"
    echo "-k (use new build kit)"
    echo "-b <extra build args like --no-cache, --pull, etc>"
    exit 1
}

DOCKER_BUILDKIT=0
BUILDARGS=""
while getopts kb: c; do
    case $c in
    k) DOCKER_BUILDKIT=1;;
    b) BUILDARGS="$OPTARG";;
    ?) usage;;
    esac
done

shift $((OPTIND - 1))

if [[ $# -ne 0 ]]; then
    usage
fi

ARM=""
if uname -m | grep -q arm; then
    ARM="-arm"
fi

export DOCKER_BUILDKIT
docker build -t bulletmark/corsproxy$ARM . $BUILDARGS
