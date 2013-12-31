#!/bin/bash

set -e
shopt -s nullglob

. "$1"/modules

for module in $GLUON_MODULES; do
	cd "$1"/$module
	git checkout -B patching base

	if [ "$1"/patches/$module/*.patch ]; then
		git am "$1"/patches/$module/*.patch || (
			git am --abort
			git checkout patched
			git branch -D patching
			false
		)
	fi
	git checkout -B patched
	git branch -d patching
done
