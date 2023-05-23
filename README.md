## Simple CORS Proxy
[![docker-amd64](https://img.shields.io/docker/v/bulletmark/corsproxy?arch=amd64&label=docker-amd64)](https://hub.docker.com/repository/docker/bulletmark/corsproxy)
[![docker-arm64](https://img.shields.io/docker/v/bulletmark/corsproxy?arch=arm64&label=docker-arm64)](https://hub.docker.com/repository/docker/bulletmark/corsproxy)
[![docker-arm/v7](https://img.shields.io/docker/v/bulletmark/corsproxy?arch=arm&label=docker-arm/v7)](https://hub.docker.com/repository/docker/bulletmark/corsproxy)

[Corsproxy][REPO] is a very small and simple but highly efficient Linux
HTTP proxy server which receives a HTTP GET or POST request on a port
and forwards that request to a pre-configured target server and port.
The proxy server then receives the HTTP reply from that server, and
returns it to the original client unaltered except that the HTTP header
has the _Access-Control-Allow-Origin_ field set to get around
[CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)
restrictions.

Why another CORS proxy program? [Existing CORS
proxies](https://github.com/search?q=cors+proxy) I found require the
originating client to specify the target host within the incoming URL to
the proxy. The proxy dynamically extracts the target host from the URL
and then sends the "real" URL to the target. [My application use
case](http://fronius-powermon.duckdns.org) only allowed me to change the
host so I could not "embed" the real host in the target URL. This simple
CORS proxy must instead be statically pre-configured with the target
server so it knows where to forward incoming requests. E.g.

    ./corsproxy 8000:192.168.1.1:9000

The above will receive requests on port 8000 and forward them to host
192.168.1.1 on port 9000.

    ./corsproxy 8000:192.168.1.1:9000 8001:192.168.1.2:9001

This runs 2 proxies. It will do as the previous example but will also
independently and asynchronously receive requests on port 8001 and
forward them to host 192.168.1.2 on port 9001. You can specify as many
proxy mappings as you want.

Instead of specifying the target mappings on the command line as above,
you can instead choose to configure them in your `~/.config/corsproxy`
file, either space delimited, or on individual lines, etc. This is
convenient if you are starting the program via
[systemd](https://www.freedesktop.org/wiki/Software/systemd/) etc. Proxy
mappings are only read from the file if none are specified on the
command line.

The receiving (i.e. listening) port and host/IP address must at least be
specified in each proxy mapping. The target port is optional and is 80
if not specified. The format, as seen in the above examples,
is `port:host[:targetport]`.

The latest version and documentation is available at
http://github.com/bulletmark/corsproxy.

## Installation

Requires `python` 3.6 or later and a modern Linux `systemd` environment
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
    $ vim ~/.config/corsproxy # Add your target servers
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

Update `~/.config/corsproxy` and `/etc/systemd/system/corsproxy.service` if
necessary. Then restart the service.

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

    docker run --restart always -d -p 8000:8000 bulletmark/corsproxy 8000:192.168.1.98

Be sure to change the target host mapping to what you require. The image
is available for amd64, arm64, and arm/v7 architectures. E.g. on a
standard PC, or on a Raspberry Pi, just run the above single command and
docker will download, install, and run the appropriate image. Docker
will also restart the corsproxy container when your system starts.

## Usage

Type `corsproxy -h` to view the following usage summary:

```
usage: corsproxy [-h] [targets ...]

Provides a simple CORS proxy for GET and POST requests. Reads list of target
port:host[:targetport] from the command line, or from your config file.

positional arguments:
  targets     1 or more proxy target hosts in port:host[:targetport] format.
              if not set then will try to read from
              ~/.config/corsproxy file.

options:
  -h, --help  show this help message and exit
```

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

[REPO]: https://github.com/bulletmark/corsproxy/

<!-- vim: se ai syn=markdown: -->
