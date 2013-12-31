#!/bin/bash

set -e

. "$1"/modules

for module in $GLUON_MODULES; do
	cd "$1"/$module
	git checkout base
done
