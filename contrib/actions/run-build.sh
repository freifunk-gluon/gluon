#!/bin/bash

export BROKEN=1
export GLUON_DEPRECATED=1
export GLUON_SITEDIR="contrib/ci/minimal-site"
export GLUON_TARGET=$1

make update
make -j2 V=s

