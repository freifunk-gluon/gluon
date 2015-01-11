#!/bin/bash

set -e

. "$GLUONDIR"/scripts/modules.sh

for module in $GLUON_MODULES; do
	cd "$GLUONDIR"/$module
	git checkout base
done
