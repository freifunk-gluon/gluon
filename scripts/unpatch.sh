#!/bin/bash

set -e

. $1/modules

for module in $GLUON_MODULES; do
	dir=$1/$module
	git -C $dir checkout base
done
