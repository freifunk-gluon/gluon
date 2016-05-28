#!/bin/bash

set -e
shopt -s nullglob

. "$GLUONDIR"/scripts/modules.sh

for module in $GLUON_MODULES; do
	cd "$GLUONDIR"/$module
	git checkout -B patching base

	for patch in "$GLUONDIR"/patches/$module/*.patch; do
		if ! git -c user.name='Gluon Patch Manager' -c user.email='gluon@void.example.com' -c commit.gpgsign=false am --whitespace=nowarn --committer-date-is-author-date "$patch"; then
			git am --abort
			git checkout patched
			git branch -D patching
			exit 1
		fi
	done
	git branch -M patched
done
