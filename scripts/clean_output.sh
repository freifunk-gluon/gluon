#!/usr/bin/env bash

set -e

[ "$LEDE_TARGET" ] || exit 1


. scripts/common.inc.sh


if [ "$(expr match "$LEDE_TARGET" '.*-.*')" -gt 0 ]; then
	LEDE_BINDIR="${LEDE_TARGET//-/\/}"
else
	LEDE_BINDIR="${LEDE_TARGET}/generic"
fi

rm -f "lede/bin/targets/${LEDE_BINDIR}"/* 2>/dev/null || true

# Full builds will output the "packages" directory, so clean up first
[ "$DEVICES" ] || rm -rf "lede/bin/targets/${LEDE_BINDIR}/packages"
