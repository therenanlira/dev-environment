#!/bin/bash

# Install code server
set -x
apk upgrade
apk --no-cache add npm alpine-sdk libstdc++ libc6-compat
npm config set python python3
git clone --recursive https://github.com/cdr/code-server.git
cd code-server
yarn global add code-server

ENV PASSWORD=changeme
ENTRYPOINT code-server --bind-addr 0:8443
