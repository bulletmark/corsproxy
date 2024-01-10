## Simple CORS Proxy
[![docker-amd64](https://img.shields.io/docker/v/bulletmark/corsproxy?arch=amd64&label=docker-amd64)](https://hub.docker.com/repository/docker/bulletmark/corsproxy)
[![docker-arm64](https://img.shields.io/docker/v/bulletmark/corsproxy?arch=arm64&label=docker-arm64)](https://hub.docker.com/repository/docker/bulletmark/corsproxy)
[![docker-arm/v7](https://img.shields.io/docker/v/bulletmark/corsproxy?arch=arm&label=docker-arm/v7)](https://hub.docker.com/repository/docker/bulletmark/corsproxy)

[Corsproxy](https://github.com/bulletmark/corsproxy/) is a small,
simple, and efficient Linux HTTP proxy service which receives a HTTP
request on a port and forwards that request to a pre-configured target
HTTP or HTTPS server. The proxy service then receives the reply from
that server, and returns it to the original client unaltered except that
the HTTP header has the _Access-Control-Allow-Origin_ field set to get
around [CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)
restrictions. It works for both IPv4 and IPv6 source and target
addresses. HTTP request methods GET, POST, PUT, PATCH, DELETE, or HEAD
are supported.

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

```sh
$ ./corsproxy 8000=http://192.168.1.1:9000
```

The above will run `corsproxy` to receive requests on port `8000` and
forward them to HTTP server `192.168.1.1:9000`.

```sh
$ ./corsproxy 8000=http://192.168.1.1:9000 8001=https://192.168.1.2:9000
```

This runs 2 independent proxies. It will do the same as the previous
example but will also independently and asynchronously receive requests
on port `8001` and forward them to HTTPS server `192.168.1.2:9000`. You
can specify as many proxy mappings as you want.

Instead of specifying the target mappings on the command line as above,
you can instead choose to configure them in `~/.config/corsproxy.toml`
a/s per the instructions in the example
[`corsproxy.toml`](corsproxy.toml) here. The file is convenient if you
are starting the program via [systemd](https://systemd.io/) etc. Proxy
mappings are only read from the file if none are specified on the
command line.

The receiving (i.e. listening) port and server/IP address must at least be
specified in each proxy mapping. The target port is optional.
The format, as seen in the above examples,
is `[host:]port=http://server[:targetport]` or `[host:]port=https://server[:targetport]`.

The latest version and documentation is available at
http://github.com/bulletmark/corsproxy.

## IPv4 and IPv6 Addresses and Examples

Originally this program was written for IPv4 address proxying only but
now handles IPv6 address proxying as well. IPv6 listening and target
hosts are specified by enclosing them in square brackets, e.g.
`[2409:d001:4c04:3a10:4d5a:3061:db17:835]` or `[::]`.

The default host address to listen for a port is `0.0.0.0` to allow all
IPv4 connections. However, you can limit to local only (i.e. loopback)
connections by specifying the host as `127.0.0.1`. Likewise, you can
specify IPv6 hosts, e.g. `[::]` for all, or `[::1]` for loopback. Some
examples follow:

```sh
# Local/loopback IPv4 address proxy:
$ ./corsproxy 127.0.0.1:8000=http://192.168.1.1

# Local/loopback IPv6 address proxy:
$ ./corsproxy [::1]:8000=http://192.168.1.1

# All IPv4 address proxy:
$ ./corsproxy 8000=http://192.168.1.1
# which same as:
$ ./corsproxy 0.0.0.0:8000=http://192.168.1.1

# All IPv6 address proxy:
$ ./corsproxy [::]:8000=http://192.168.1.1

# Use 2 mappings for both IPv4 and IPv6 hosts:
# [Note that Python asyncio does not allow dual stack IPv4/IPv6 so
# must run 2 separate mappings]
$ ./corsproxy 8000=http://192.168.1.1 [::]:8000=http://192.168.1.1

# Forward IPv4 HTTP to IPv6 HTTPS server (on it's port 9000):
$ ./corsproxy 8000=https://[2409:d001:4c04:3a10:4d5a:3061:db17:835]:9000
```

## Installation

Requires `python` 3.7 or later and any modern
[systemd](https://systemd.io/)  based Linux environment. E.g. I run it
on a [Raspberry Pi](https://www.raspberrypi.com/) using [Arch Linux
ARM](https://archlinuxarm.org/).

These instructions assume you are using [systemd](https://systemd.io/)
to start the application. A [systemd
service](https://www.freedesktop.org/software/systemd/man/systemd.service.html)
service file is provided.

1. Clone repository and create configuration:

    ```sh
    $ git clone https://github.com/bulletmark/corsproxy
    $ cd corsproxy
    $ mkdir -p ~/.config
    $ cp corsproxy.toml ~/.config
    $ vim ~/.config/corsproxy.toml # Add your target servers
    ```

2. Create virtual environment (venv) and install service:

    ```sh
    $ python3 -m venv venv
    $ venv/bin/pip install -r requirements.txt
    $ sudo cp corsproxy.service /etc/systemd/system
    $ sudoedit /etc/systemd/system/corsproxy.service # Edit #TEMPLATE# values.
    ```

Note: Alternatively, to create the venv, install the requirement
packages, insert the template values, and enable + start the service you
can use my [pinstall](https://github.com/bulletmark/pinstall) tool. Just
install it and do the following in the `corsproxy` directory.

```sh
$ pinstall venv
$ pinstall service
```

## Starting, Stopping, And Status

To enable starting at boot and also start immediately:

```sh
$ sudo systemctl enable corsproxy
$ sudo systemctl start corsproxy
```

To stop immediately and also disable starting at boot:

```sh
$ sudo systemctl stop corsproxy
$ sudo systemctl disable corsproxy
```

Show status:

```sh
$ systemctl status corsproxy
```

Show log:

```sh
$ journalctl -u corsproxy
```

## Upgrade

`cd` to source directory, as above. Then update the source:

```sh
$ git pull
```

Update `~/.config/corsproxy.toml` and
`/etc/systemd/system/corsproxy.service` if necessary. Then restart the
service.

```sh
$ sudo systemctl restart corsproxy
```

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

```sh
$ docker run --restart always -d -p 8000:8000 bulletmark/corsproxy 8000=http://192.168.1.98
```

Be sure to change the target server mapping to what you require. The image
is available for amd64, arm64, and arm/v7 architectures. E.g. on a
standard PC, or on a Raspberry Pi, just run the above single command and
docker will download, install, and run the appropriate image. Docker
will also restart the corsproxy container when your system starts.

## Usage

Type `corsproxy -h` to view the usage summary:

```
usage: corsproxy [-h] [-d] [-c CONFFILE] [targets ...]

A simple CORS proxy. Reads list of target server mappings from the command
line, or from your config file. Target server mappings are of the form
"[host:]port=http://server[:targetport]" or
"[host:]port=https://server[:targetport]" where "port" is the local listening
port and "server[:targetport]" is the server (and optional target port) to
proxy to. The default host address to listen on for a port is '0.0.0.0' to
allow all IPv4 connections but you can specify an alternate host address for
each server mapping, e.g. '127.0.0.1' to limit to local IPv4 connections, or
'[::]' for all IPv6 connections, or '[::1]' to limit to local IPv6
connections, or any specific IPv4 or IPv6 address to limit to that interface.
E.g. to listen all IPv4 and IPv6 addresses and forward to same IPv4 server
define 2 mappings: "0.0.0.0:8000=http://192.168.1.1"
"[::]:8000=http://192.168.1.1".

positional arguments:
  targets               1 or more proxy target server mappings

options:
  -h, --help            show this help message and exit
  -d, --debug           enable debug output
  -c CONFFILE, --conffile CONFFILE
                        alternative configuration file,
                        default="~/.config/corsproxy.toml"
```

## Major Version 2.0 Changes

1. **Incompatible Change:** HTTPS targets are now supported in addition
   to standard HTTP. This necessitates an incompatible change to how the
   target server mappings are defined. E.g. a previous mapping
   `8000:192.168.1.98` now must be defined as `8000=http://192.168.1.98`
   because you are required to define whether the target server is
   `http` or `https`. Note the listening port is now separated from the
   target server with a `=`, not a `:`.

2. **Incompatible Change:** The configuration file `~/.config/corsproxy`
   is renamed to `~/.config/corsproxy.toml` and is now
   [TOML](https://toml.io) format.

3. **Enhancement:** IPv6 addresses can now also be specified for both
   source and target addresses, in addition to IPv4 addresses.
   Also, source addresses for IPv4 and IPv6 can be specified to limit to
   loopback interface only, or to a specific interface, etc.

4. **Enhancement:** HTTP methods PUT, PATCH, DELETE, and HEAD are now
   supported in addition to the normal GET and POST.

5. **Enhancement:** Previously I was using a home-grown implementation
   to intercept and insert
   [CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)
   headers. This worked for my use but it may not work generally for all
   users so now I use the [Starlette](https://www.starlette.io/)
   middleware [CORS
   package](https://www.starlette.io/middleware/#corsmiddleware) which
   is likely to be much more standards based and robust for general use.

6. **Enhancement:** For concurrency, the code now uses native Python
   [asyncio](https://docs.python.org/3/library/asyncio.html) rather than
   3rd party
   [gevent/greenlet](https://greenlet.readthedocs.io/en/latest/) so it
   is slightly more performant and efficient.

7. Python 3.7+ is required at a minimum. Python 3.6 no longer supported.

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
