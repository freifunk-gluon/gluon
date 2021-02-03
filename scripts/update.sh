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
		for repository in $repo; do
			if git fetch "$repository" "$branch"; then
				if ! git branch -f base "$commit"; then
					echo "unable to find commit \"$commit\" on branch \"$branch\" in repo \"$repo\"." >&2
					break
				fi
				fetched=1
				break
			else
				echo "unable to fetch module \"$module\" from \"$repository\"" >&2
			fi
		done

		if [ $fetched -ne 1 ]; then
			echo "No suitable mirror for module \"$module\" found." >&2
			exit 1
		fi
	fi
done
