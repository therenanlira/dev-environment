#!/bin/bash

# Install code server
apk update
apk upgrade
apk add alpine-sdk gcompat libstdc++ libc6-compat build-base bash python3 nodejs-current npm yarn argon2
wget https://code.visualstudio.com/sha/download?build=stable&os=linux-armhf
npm config set python python3
npm install --global code-server --unsafe-perm
