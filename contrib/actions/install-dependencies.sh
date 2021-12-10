#!/bin/sh

set -e

apt-get -y update
apt-get -y install git subversion build-essential python3 gawk unzip libncurses5-dev zlib1g-dev libssl-dev wget time qemu-utils
apt-get -y clean
rm -rf /var/lib/apt/lists/*
