#!/bin/bash

set -e
shopt -s nullglob

. "$1"/modules

for module in $GLUON_MODULES; do
	dir="$1"/$module
	git -C "$dir" checkout patched

	rm -f "$1"/patches/$module/*.patch
	mkdir -p "$1"/patches/$module
	git -C "$dir" format-patch -o "$1"/patches/$module base 
done
