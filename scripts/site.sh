#!/bin/sh

export GLUONDIR="$(dirname "$0")/.."

echo "@$1@" | $GLUONDIR/scripts/configure.pl $GLUONDIR/scripts/generate.pl
