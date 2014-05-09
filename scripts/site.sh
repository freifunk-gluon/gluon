#!/bin/sh

export GLUONDIR="$(dirname "$0")/.."

RESULT=$(echo "@$1@" | $GLUONDIR/scripts/configure.pl $GLUONDIR/scripts/generate.pl)
test ! "$RESULT" = "@$1@" && echo $RESULT
