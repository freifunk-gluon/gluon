#!/bin/bash

set -e
shopt -s nullglob

. "$GLUONDIR"/scripts/modules.sh

for module in $GLUON_MODULES; do
	echo "--- Updating patches for module '$module' ---"

	rm -f "$GLUONDIR"/patches/$module/*.patch
	mkdir -p "$GLUONDIR"/patches/$module

	cd "$GLUONDIR"/$module

	n=0
	for commit in $(git rev-list --reverse --no-merges base..patched); do
		let n=n+1
		git show --pretty=format:'From: %an <%ae>%nDate: %aD%nSubject: %B' $commit > "$GLUONDIR"/patches/$module/"$(printf '%04u' $n)-$(git show -s --pretty=format:%f $commit).patch"
	done
done
