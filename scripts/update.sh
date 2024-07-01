#!/bin/bash

set -e

. scripts/modules.sh


GLUONDIR="$(pwd)"

for module in $GLUON_MODULES; do
	echo "--- Updating module '$module' ---"
	var=${module//\//_}
	_remote_url=${var^^}_REPO
	_remote_branch=${var^^}_BRANCH
	_remote_commit=${var^^}_COMMIT

	repo=${!_remote_url}
	branch=${!_remote_branch}
	commit=${!_remote_commit}

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
