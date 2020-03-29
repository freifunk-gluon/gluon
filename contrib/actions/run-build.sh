#!/bin/bash

sudo apt install git subversion build-essential python gawk unzip libncurses5-dev zlib1g-dev libssl-dev wget time

export BROKEN=1
export GLUON_DEPRECATED=1
export GLUON_SITEDIR="contrib/ci/minimal-site"
export GLUON_TARGET=$1

make update
make -j2

