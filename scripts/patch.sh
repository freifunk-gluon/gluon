#!/bin/bash

set -e
shopt -s nullglob

. "$1"/modules

for module in $GLUON_MODULES; do
	dir="$1"/$module
	git -C $dir checkout -B patching base

	if [ -z "$1"/patches/$module/*.patch ]; then continue; fi
	git -C "$dir" am "$1"/patches/$module/*.patch || (
		git -C "$dir" am --abort
		git -C "$dir" checkout patched
		git -C "$dir" branch -D patching
		false
	)
	git -C "$dir" checkout -B patched
	git -C "$dir" branch -d patching
done
