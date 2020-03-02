#!/bin/bash

set -e

. scripts/modules.sh


GLUONDIR="$(pwd)"

for module in $GLUON_MODULES; do
	echo "--- Updating module '$module' ---"
	var=$(echo "$module" | tr '[:lower:]/' '[:upper:]_')
	eval 'repo=${'"${var}"'_REPO}'
	eval 'branch=${'"${var}"'_BRANCH}'
	eval 'commit=${'"${var}"'_COMMIT}'

	mkdir -p "$GLUONDIR/$module"
	cd "$GLUONDIR/$module"
	git init

	if ! git branch -f base "$commit" 2>/dev/null; then
		git fetch "$repo" "$branch"
		git branch -f base "$commit" || {
		  echo "unable to find commit \"$commit\" on branch \"$branch\" in repo \"$repo\"." >&2
		  exit 1
		}
	fi
done
