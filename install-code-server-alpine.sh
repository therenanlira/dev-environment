#!/bin/bash

# Install code server
apk update
apk upgrade
apk --no-cache add alpine-sdk libstdc++ libc6-compat
apk add nodejs npm --repository http://dl-cdn.alpinelinux.org/alpine/v3.16/main
curl -fsSL https://code-server.dev/install.sh | sh

# npm config set python python3
# git clone --recursive https://github.com/cdr/code-server.git
# cd code-server
# yarn global add code-server

# ENV PASSWORD=changeme
# ENTRYPOINT code-server --bind-addr 0:8443
