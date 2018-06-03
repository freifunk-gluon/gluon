#!/usr/bin/env bash

set -e

[ "$OPENWRT_TARGET" ] || exit 1


. scripts/common.inc.sh


if [ "$(expr match "$OPENWRT_TARGET" '.*-.*')" -gt 0 ]; then
	OPENWRT_BINDIR="${OPENWRT_TARGET//-/\/}"
else
	OPENWRT_BINDIR="${OPENWRT_TARGET}/generic"
fi

rm -f "openwrt/bin/targets/${OPENWRT_BINDIR}"/* 2>/dev/null || true

# Full builds will output the "packages" directory, so clean up first
[ "$DEVICES" ] || rm -rf "openwrt/bin/targets/${OPENWRT_BINDIR}/packages"
