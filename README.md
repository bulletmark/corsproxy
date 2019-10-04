### Simple CORS Proxy

[Corsproxy][REPO] is a very small and simple Linux HTTP server
application which receives HTTP GET or POST requests on a port and
forwards those requests to a pre-configured target server and port. The
proxy receives HTTP replies and returns them to the original client
unaltered except that the HTTP header has the
_Access-Control-Allow-Origin_ field set to get around
[CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)
restrictions.

Why another CORS proxy program? [Existing CORS
proxies](https://github.com/search?q=cors+proxy) I found require the
originating client to specify the target host within the incoming URL to
the proxy. The proxy dynamically extracts the target host and then sends
the "real" URL to the target. [My application use
case](http://fronius-powermon.duckdns.org) only allowed me to change the
host so I could not "embed" the real host in the target URL. This simple
CORS proxy must be statically pre-configured with the target server so
it knows where to forward incoming requests. E.g.

    ./corsproxy 8000:192.168.1.1:9000

The above will receive requests on port 8000 and forward them to host
192.168.1.1 on port 9000.

    ./corsproxy 8000:192.168.1.1:9000 8001:192.168.1.2:9001

This runs 2 proxies. It will do as the previous example but will also
independently receive requests on port 8001 and forward them to host
192.168.1.2 on port 9001. You can specify as many proxy mappings as you
want.

Instead of specifying the target mappings on the command line as above,
you can instead choose to configure them in your `~/.config/corsproxy`
file, either space delimitered, or on individual lines, etc. This is
convenient if you are starting the program via
[systemd](https://www.freedesktop.org/wiki/Software/systemd/) etc.

The target port is 80 on a host mapping if you do not specify it.

The latest version and documentation is available at
http://github.com/bulletmark/corsproxy.

### INSTALLATION

Requires Python 3.5 or later on a Linux server (I use a Raspberry Pi). A
[systemd
service](https://www.freedesktop.org/software/systemd/man/systemd.service.html)
service file is provided to start the application at system startup.

git clone https://github.com/bulletmark/corsproxy
cd corsproxy
python3 -m venv env
env/bin/pip install -r requirements.txt
mkdir -p ~/.config
vim ~/.config/corsproxy # Add the target servers
sudo cp corsproxy.service /etc/systemd/system
sudo vim /etc/systemd/system/corsproxy.service # Edit #TEMPLATE# values.

### STARTING, STOPPING, AND STATUS

If you are starting this program via
[systemd](https://www.freedesktop.org/wiki/Software/systemd/) then you
can use the following commands.

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

### UPGRADE

`cd` to source dir, as above. Then update the source:

    git pull

Update `~/.config/corsproxy` and `/etc/systemd/system/corsproxy.service` if
necessary. Then restart the service.

    sudo systemctl restart corsproxy

### DOCKER

A Docker image is available on Docker Hub:

    docker run --restart always -d -p 8000:8000 bulletmark/corsproxy 8000:192.168.1.98

There is also an ARM image (e.g. for Raspberry Pi):

    docker run --restart always -d -p 8000:8000 bulletmark/corsproxy-arm 8000:192.168.1.98

### USAGE

```
usage: corsproxy [-h] [targets [targets ...]]

Provides a simple CORS proxy for GET requests. Reads list of target
port:host[:targetport] from the command line, or from your config file.

positional arguments:
  targets     1 or more proxy target hosts in port:host[:targetport] format.
              if not set then will try to read from ~/.config/corsproxy file.

optional arguments:
  -h, --help  show this help message and exit
```

### LICENSE

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
