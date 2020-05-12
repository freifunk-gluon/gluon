#!/bin/sh

set -e

cp contrib/actions/sources.list /etc/apt/sources.list
rm -rf /etc/apt/sources.list.d
apt update
apt install git subversion build-essential python gawk unzip libncurses5-dev zlib1g-dev libssl-dev wget time
apt clean
rm -rf /var/lib/apt/lists/*
