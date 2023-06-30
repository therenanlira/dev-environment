#!/bin/bash

# Install code server
apk update
apk upgrade
# apk add nodejs npm --repository http://dl-cdn.alpinelinux.org/alpine/v3.16/main
apk add alpine-sdk gcompat libstdc++ libc6-compat build-base bash python3 nodejs-current npm
npm config set python python3
npm install --global code-server --unsafe-perm

# curl -fsSL https://code-server.dev/install.sh | sh
# npm config set python python3
# git clone --recursive https://github.com/cdr/code-server.git
# cd code-server
# yarn global add code-server

# ENV PASSWORD=changeme
# ENTRYPOINT code-server --bind-addr 0:8443
