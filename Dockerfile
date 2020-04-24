FROM python:3.8-alpine as base
LABEL name=corsproxy maintainer="mark.blakeney@bullet-systems.net"

FROM base as builder
RUN apk add --no-cache build-base libffi-dev
RUN mkdir /install
WORKDIR /install

COPY requirements.txt /
RUN pip install --prefix=/install -r /requirements.txt

FROM base
COPY --from=builder /install /usr/local/
WORKDIR /app
COPY . ./

ENTRYPOINT ["python", "-u", "corsproxy"]
