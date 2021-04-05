#!/bin/sh

set -e

cp contrib/actions/sources.list /etc/apt/sources.list
rm -rf /etc/apt/sources.list.d
apt-get update
apt-get install git subversion build-essential python gawk unzip libncurses-dev zlib1g-dev libssl-dev wget time
apt-get clean
rm -rf /var/lib/apt/lists/*
