#!/bin/bash
# shellcheck enable=check-unassigned-uppercase

set -e
shopt -s nullglob

[ "$GLUON_TMPDIR" ] && [ "$GLUON_PATCHESDIR" ] || exit 1

. scripts/modules.sh


mkdir -p "$GLUON_TMPDIR"

GLUONDIR="$(pwd)"

PATCHDIR="$GLUON_TMPDIR"/patching
trap 'rm -rf "$PATCHDIR"' EXIT

for module in $GLUON_MODULES; do
	echo "--- Patching module '$module' ---"

	git clone -s -b base --single-branch "$GLUONDIR/$module" "$PATCHDIR" 2>/dev/null

	cd "$PATCHDIR"
	for patch in "${GLUON_PATCHESDIR}/$module"/*.patch; do
		git -c user.name='Gluon Patch Manager' -c user.email='gluon@void.example.com' -c commit.gpgsign=false am --whitespace=nowarn --committer-date-is-author-date "$patch"
	done

	cd "$GLUONDIR/$module"
	git fetch "$PATCHDIR" 2>/dev/null
	git checkout -B patched FETCH_HEAD >/dev/null

	git config branch.patched.remote .
	git config branch.patched.merge refs/heads/base

	git submodule update --init --recursive

	rm -rf "$PATCHDIR"
done
