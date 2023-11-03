#!/bin/sh

set -e

export BROKEN=1
export GLUON_AUTOREMOVE=1
export GLUON_DEPRECATED=1
export GLUON_SITEDIR="${GLUON_SITEDIR:-contrib/ci/minimal-site}"
export GLUON_TARGET="$1"
export BUILD_LOG=1

BUILD_THREADS="$(($(nproc) + 1))"

echo "Building Gluon with $BUILD_THREADS threads"

echo "${GLUON_SITEDIR}"
tree "${GLUON_SITEDIR}"

echo "GLUON_AUTOUPDATER_ENABLED: ${GLUON_AUTOUPDATER_ENABLED}"
echo "GLUON_AUTOUPDATER_BRANCH: ${GLUON_AUTOUPDATER_BRANCH}"

make update
make -j$BUILD_THREADS V=s
