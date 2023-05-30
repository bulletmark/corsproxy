## Simple CORS Proxy
[![docker-amd64](https://img.shields.io/docker/v/bulletmark/corsproxy?arch=amd64&label=docker-amd64)](https://hub.docker.com/repository/docker/bulletmark/corsproxy)
[![docker-arm64](https://img.shields.io/docker/v/bulletmark/corsproxy?arch=arm64&label=docker-arm64)](https://hub.docker.com/repository/docker/bulletmark/corsproxy)
[![docker-arm/v7](https://img.shields.io/docker/v/bulletmark/corsproxy?arch=arm&label=docker-arm/v7)](https://hub.docker.com/repository/docker/bulletmark/corsproxy)

[Corsproxy](https://github.com/bulletmark/corsproxy/) is a very small
and simple but efficient Linux HTTP proxy service which receives a HTTP
request (GET, POST, PUT, PATCH, DELETE, or HEAD) on a port and forwards
that request to a pre-configured target HTTP or HTTPS server. The proxy
service then receives the reply from that server, and returns it to the
original client unaltered except that the HTTP header has the
_Access-Control-Allow-Origin_ field set to get around
[CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)
restrictions.

Why another CORS proxy program? [Existing CORS
proxies](https://github.com/search?q=cors+proxy) I found require the
originating client to specify the target server as an option/parameter
within the incoming URL to the proxy. The proxy dynamically extracts the
target server from the URL and then sends the "real" URL to the target.
[My application use case](http://fronius-powermon.duckdns.org) only
allowed me to change the server name so I could not "embed" the real
server in the target URL. This simple CORS proxy must instead be
statically pre-configured with the target server so it knows where to
forward incoming requests. E.g.

    ./corsproxy 8000=http://192.168.1.1:9000

The above will run `corsproxy` to receive requests on port 8000 and
forward them to HTTP server 192.168.1.1:9000.

    ./corsproxy 8000=http://192.168.1.1:9000 8001=https://192.168.1.2:9000

This runs 2 independent proxies. It will do the same as the previous
example but will also independently and asynchronously receive requests
on port 8001 and forward them to HTTPS server 192.168.1.2:9000. You can
specify as many proxy mappings as you want.

Instead of specifying the target mappings on the command line as above,
you can instead choose to configure them in `~/.config/corsproxy.toml`
a/s per the instructions in the example
[`corsproxy.toml`](corsproxy.toml) here. The file is convenient if you
are starting the program via
[systemd](https://www.freedesktop.org/wiki/Software/systemd/) etc. Proxy
mappings are only read from the file if none are specified on the
command line.

The receiving (i.e. listening) port and server/IP address must at least be
specified in each proxy mapping. The target port is optional.
The format, as seen in the above examples,
is `port=http://server[:targetport]` or `port=https://server[:targetport]`.

The latest version and documentation is available at
http://github.com/bulletmark/corsproxy.

## Installation

Requires `python` 3.7 or later and a modern Linux `systemd` environment
(I use a Raspberry Pi).

These instructions assume you are using
[systemd](https://www.freedesktop.org/wiki/Software/systemd/) to start
the application. A [systemd
service](https://www.freedesktop.org/software/systemd/man/systemd.service.html)
service file is provided.

1. Clone repository and create configuration:

    ```shell
    $ git clone https://github.com/bulletmark/corsproxy
    $ cd corsproxy
    $ mkdir -p ~/.config
    $ cp corsproxy.toml ~/.config
    $ vim ~/.config/corsproxy.toml # Add your target servers
    ```

2. Create virtual environment (venv) and install service:

    ```shell
    $ python3 -m venv venv
    $ venv/bin/pip install -r requirements.txt
    $ sudo cp corsproxy.service /etc/systemd/system
    $ sudoedit /etc/systemd/system/corsproxy.service # Edit #TEMPLATE# values.
    ```

Note: Alternatively, to create the venv, install the requirement
packages, insert the template values, and enable + start the service you
can use my [pinstall](https://github.com/bulletmark/pinstall) tool. Just
install it and do the following in the `corsproxy` directory.

```
$ pinstall venv
$ pinstall service
```

## Starting, Stopping, And Status

To enable starting at boot and also start immediately:

    sudo systemctl enable corsproxy
    sudo systemctl start corsproxy

To stop immediately and also disable starting at boot:

    sudo systemctl stop corsproxy
    sudo systemctl disable corsproxy

Show status:

    systemctl status corsproxy

Show log:

    journalctl -u corsproxy

## Upgrade

`cd` to source directory, as above. Then update the source:

    git pull

Update `~/.config/corsproxy.toml` and
`/etc/systemd/system/corsproxy.service` if necessary. Then restart the
service.

    sudo systemctl restart corsproxy

## Docker

Alternatively, for many users it may be easier to install and run this
application using [Docker](https://www.docker.com/get-started). Follow
your Linux distribution's instructions to ensure Docker is
[installed](https://docs.docker.com/engine/install/) and enabled to
automatically start at boot. Also ensure you [add your
user](https://docs.docker.com/engine/install/linux-postinstall/) to the
`docker` group.

The Docker image is available on [Docker
Hub](https://hub.docker.com/repository/docker/bulletmark/corsproxy). Run
the following command:

    docker run --restart always -d -p 8000:8000 bulletmark/corsproxy 8000=http://192.168.1.98

Be sure to change the target server mapping to what you require. The image
is available for amd64, arm64, and arm/v7 architectures. E.g. on a
standard PC, or on a Raspberry Pi, just run the above single command and
docker will download, install, and run the appropriate image. Docker
will also restart the corsproxy container when your system starts.

## Usage

Type `corsproxy -h` to view the usage summary:

```
usage: corsproxy [-h] [-d] [-b BIND_HOST] [-c CONFFILE] [targets ...]

A simple CORS proxy. Reads list of target port=http://server[:targetport] from
the command line, or from your config file.

positional arguments:
  targets               1 or more proxy target servers in format
                        "port=http://server[:targetport]" or
                        "port=https://server[:targetport]" where "port" is the
                        local listening port and "server[:targetport]" is the
                        server (and optional target port) to proxy to.

options:
  -h, --help            show this help message and exit
  -d, --debug           enable debug output
  -b BIND_HOST, --bind-host BIND_HOST
                        bind listening sockets to this host, default="0.0.0.0"
  -c CONFFILE, --conffile CONFFILE
                        alternative configuration file,
                        default="~/.config/corsproxy.toml"
```

## Version Major Version 2.0 Changes

1. **Incompatible Change:** HTTPS targets are now supported in addition
   to standard HTTP. This necessitates an incompatible change to how the
   target server mappings are defined. E.g. a previous mapping
   `8000:192.168.1.98` now must be defined as `8000=http://192.168.1.98`
   because you are required to define whether the target server is
   `http` or `https`. Note the listening port is now separated from the
   target server with a `=`, not a `:`.

2. **Incompatible Change:** The configuration file `~/.config/corsproxy`
   is renamed to `~/.config/corsproxy.toml` and is now
   [TOML](https://toml.io) format because you can now configure other
   command line settings (presently only `--bind-host`) in addition to
   the target server mappings in that file.

3. **Enhancement:** HTTP methods PUT, PATCH, DELETE, and HEAD are now
   supported in addition to the normal GET and POST.

4. **Enhancement:** Previously I was using a home-grown implementation to
   intercept and insert
   [CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)
   headers. This worked for my use but it may not work generally for all
   users so now I use the [Starlette](https://www.starlette.io/)
   middleware [CORS
   package](https://www.starlette.io/middleware/#corsmiddleware) which
   is likely to be much more standards based, resilient, and general
   purpose.

5. **Enhancement:** For concurrency, the code now uses Python
   [asyncio](https://docs.python.org/3/library/asyncio.html) rather than
   [gevent/greenlet](https://greenlet.readthedocs.io/en/latest/) so it
   is slightly more performant and efficient.

6. Python 3.7+ is required at a minimum. Python 3.6 no longer supported.

## License

Copyright (C) 2019 Mark Blakeney. This program is distributed under the
terms of the GNU General Public License.
This program is free software: you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation, either version 3 of the License, or any later
version.
This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
Public License at <http://www.gnu.org/licenses/> for more details.

<!-- vim: se ai syn=markdown: -->
