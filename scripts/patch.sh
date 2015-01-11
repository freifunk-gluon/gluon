#!/bin/bash

set -e
shopt -s nullglob

. "$GLUONDIR"/scripts/modules.sh

for module in $GLUON_MODULES; do
	cd "$GLUONDIR"/$module
	git checkout -B patching base

	if [ "$(echo "$GLUONDIR"/patches/$module/*.patch)" ]; then
		git am --whitespace=nowarn "$GLUONDIR"/patches/$module/*.patch || (
			git am --abort
			git checkout patched
			git branch -D patching
			false
		)
	fi
	git branch -M patched
done
