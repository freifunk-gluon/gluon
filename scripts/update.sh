#!/bin/bash

set -e

. $1/modules

for module in $GLUON_MODULES; do
	dir=$1/$module
	mkdir -p $dir
	var=$(echo "$module" | tr '[:lower:]/' '[:upper:]_')
	eval repo=\${MODULE_${var}_REPO}
	eval commit=\${MODULE_${var}_COMMIT}
	git -C $dir init
	git -C $dir fetch $repo
	git -C $dir checkout -B base $commit
done
