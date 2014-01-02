#!/bin/bash

set -e
shopt -s nullglob

. "$1"/scripts/modules.sh

for module in $GLUON_MODULES; do
	rm -f "$1"/patches/$module/*.patch
	mkdir -p "$1"/patches/$module

	cd "$1"/$module

	n=0
	for commit in $(git rev-list --reverse --no-merges base..patched); do
		let n=n+1
		git show --pretty=format:'From: %an <%ae>%nDate: %aD%nSubject: %B' $commit > "$1"/patches/$module/"$(printf '%04u' $n)-$(git show -s --pretty=format:%f $commit).patch"
	done
done
