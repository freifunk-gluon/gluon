#!/bin/sh

set -e

apt-get update
apt-get install git subversion build-essential python gawk unzip libncurses-dev zlib1g-dev libssl-dev wget time
apt-get clean
rm -rf /var/lib/apt/lists/*
