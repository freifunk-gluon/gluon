#!/bin/bash

set -e
shopt -s nullglob

. "$1"/scripts/modules.sh

for module in $GLUON_MODULES; do
	cd "$1"/$module
	git checkout -B patching base

	if [ "$(echo "$1"/patches/$module/*.patch)" ]; then
		git am --whitespace=nowarn "$1"/patches/$module/*.patch || (
			git am --abort
			git checkout patched
			git branch -D patching
			false
		)
	fi
	git branch -M patched
done
