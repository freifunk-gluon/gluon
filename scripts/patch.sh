#!/bin/bash

set -e
shopt -s nullglob

. "$1"/modules

for module in $GLUON_MODULES; do
	dir="$1"/$module
	git -C $dir checkout -B patched base

	if [ -z "$1"/patches/$module/*.patch ]; then continue; fi
	git -C "$dir" am "$1"/patches/$module/*.patch
done
