#!/bin/bash

set -e
shopt -s nullglob

. scripts/modules.sh


GLUONDIR="$(pwd)"

for module in $GLUON_MODULES; do
	echo "--- Updating patches for module '$module' ---"

	rm -rf "$GLUONDIR"/patches/"$module"

	cd "$GLUONDIR"/"$module"

	n=0
	for commit in $(git rev-list --reverse --no-merges base..patched); do
		let n=n+1
		mkdir -p "$GLUONDIR"/patches/"$module"
		git -c core.abbrev=40 show --pretty=format:'From: %an <%ae>%nDate: %aD%nSubject: %B' --no-renames "$commit" > "$GLUONDIR/patches/$module/$(printf '%04u' $n)-$(git show -s --pretty=format:%f "$commit").patch"
	done
done
