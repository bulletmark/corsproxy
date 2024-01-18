FROM python:3.11-slim as base
LABEL name=corsproxy maintainer="mark.blakeney@bullet-systems.net"

FROM base as builder
RUN apt-get update && apt-get install -y --no-install-recommends build-essential libffi-dev
RUN mkdir /install
WORKDIR /install

COPY requirements.txt /
RUN pip install \
    --disable-pip-version-check \
    --no-python-version-warning \
    --no-warn-script-location \
    --no-cache \
    --prefix=/install \
    -r /requirements.txt

FROM base
COPY --from=builder /install /usr/local/
WORKDIR /app
COPY . ./

ENTRYPOINT ["python3", "corsproxy"]
