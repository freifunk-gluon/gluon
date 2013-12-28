#!/bin/bash

set -e
shopt -s nullglob

. "$1"/modules

for module in $GLUON_MODULES; do
	dir="$1"/$module
	rm -f "$1"/patches/$module/*.patch
	mkdir -p "$1"/patches/$module

	n=0
	for commit in $(git -C "$dir" rev-list --reverse --no-merges base..patched); do
		let n=n+1
		git -C "$dir" show --pretty=format:'From: %an <%ae>%nDate: %aD%nSubject: %B' $commit > "$1"/patches/$module/"$(printf '%04u' $n)-$(git -C "$dir" show -s --pretty=format:%f).patch"
	done
done
