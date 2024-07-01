#!/bin/bash
# shellcheck enable=check-unassigned-uppercase

set -e
shopt -s nullglob

[ "$GLUON_PATCHESDIR" ] || exit 1

. scripts/modules.sh


GLUONDIR="$(pwd)"

for module in $GLUON_MODULES; do
	echo "--- Updating patches for module '$module' ---"

	rm -rf "${GLUON_PATCHESDIR:?}/$module"

	cd "$GLUONDIR"/"$module"

	n=0
	for commit in $(git rev-list --reverse --no-merges base..patched); do
		(( ++n ))
		mkdir -p "${GLUON_PATCHESDIR}/$module"
		echo "Updating: $(git log --format=%s -n 1 "$commit")"
		git -c core.abbrev=40 show --pretty=format:'From: %an <%ae>%nDate: %aD%nSubject: %B' --no-renames --binary "$commit" > "${GLUON_PATCHESDIR}/$module/$(printf '%04u' "$n")-$(git show -s --pretty=format:%f "$commit").patch"
	done
done
