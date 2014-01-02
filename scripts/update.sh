#!/bin/bash

set -e

. "$1"/scripts/modules.sh

for module in $GLUON_MODULES; do
	var=$(echo $module | tr '[:lower:]/' '[:upper:]_')
	eval repo=\${${var}_REPO}
	eval commit=\${${var}_COMMIT}

	mkdir -p "$1"/$module
	cd "$1"/$module
	git init

	git checkout $commit 2>/dev/null || git fetch $repo
	git checkout -B base $commit
done
