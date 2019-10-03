FROM python:3.7-alpine as base
LABEL name=corsproxy maintainer="mark.blakeney@bullet-systems.net"

FROM base as builder
RUN apk add --no-cache build-base
RUN mkdir /install
WORKDIR /install

COPY requirements.txt /
RUN pip install --install-option="--prefix=/install" -r /requirements.txt

FROM base
COPY --from=builder /install /usr/local/
WORKDIR /app
COPY . ./

ENTRYPOINT ["python", "-u", "corsproxy"]
