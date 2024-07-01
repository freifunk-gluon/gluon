#!/bin/bash

set -e

. scripts/modules.sh

GLUONDIR="$(pwd)"

if [ ! -d "$GLUONDIR/openwrt" ]; then
	echo "You don't seem to have obtained the external repositories needed by Gluon; please call \`make update\` first!"
	exit 1
fi

need_sync=false

for module in $GLUON_MODULES; do
	echo "Checking module '$module'"
	var=${module//\//_}
	_remote_commit=${var^^}_COMMIT
	commit_expected=${!_remote_commit}

	prefix=invalid
	cd "$GLUONDIR/$module" 2>/dev/null && prefix="$(git rev-parse --show-prefix 2>/dev/null)"
	if [ "$prefix" ]; then
		echo "*** No Git repository found at '$module'."
		need_sync=true
		continue
	fi

	commit_actual="$(git rev-parse heads/base 2>/dev/null)"
	if [ -z "$commit_actual" ]; then
		echo "*** No base branch found at '$module'."
		need_sync=true
		continue
	fi

	if [ "$commit_expected" != "$commit_actual" ]; then
		echo "*** base branch at '$module' did not match module file (expected: ${commit_expected}, actual: ${commit_actual})"
		need_sync=true
		continue
	fi

	# Use git status instead of git diff -q, as the latter doesn't
	# check for untracked files
	if [ "$(git status --porcelain 2>/dev/null | wc -l)" -ne 0 ]; then
		echo "*** Module '$module' has uncommitted changes:"
		git status --short
	fi
done

if $need_sync; then
	echo
	# shellcheck disable=SC2016
	echo 'Run `make update` to sync dependencies.'
	echo
fi
