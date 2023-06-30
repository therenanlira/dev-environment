#!/bin/bash

# Install basic packages
apk update
apk add --no-cache sudo curl wget vim bash git

# Install sudo and configure user coder
adduser -D coder
echo "coder:Docker!" | chpasswd
echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
chown -R coder: /home/coder/

# Configure 
echo -e \
'SHELL="/bin/ash"
PYTHONPATH="/usr/local/lib/python3-*/site-packages"
PS1="\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\] \w\[\033[00m\]\\n$ \[\]"

# Functions
findhere() { find . -name "*$1*"; }
opensslcert() { openssl s_client -showcerts -connect $1:443; }
curlcert() { curl $1 -vI --stderr -; }

# Alias
alias ll="ls -la"
' >> /home/coder/.profile
