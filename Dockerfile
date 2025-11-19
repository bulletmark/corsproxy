FROM python:3.13-slim AS base
LABEL name=corsproxy maintainer="mark.blakeney@bullet-systems.net"

FROM base AS builder
RUN apt-get update && apt-get install -y --no-install-recommends build-essential libffi-dev pipx
RUN pipx install --global uv
RUN mkdir /install
WORKDIR /install

COPY requirements.txt /
RUN uv pip install \
    --no-cache \
    --prefix=/install \
    -r /requirements.txt

FROM base
COPY --from=builder /install /usr/local/
WORKDIR /app
COPY . ./

ENTRYPOINT ["python3", "corsproxy"]
