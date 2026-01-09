#!/usr/bin/env bash

set -euo pipefail

echo "CONFIG_DEVEL=y"
if [ "$GLUON_AUTOREMOVE" != "0" ]; then
	echo "CONFIG_AUTOREMOVE=y"
else
	echo "# CONFIG_AUTOREMOVE is not set"
fi
