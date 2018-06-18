#!/bin/bash

set -e

. scripts/modules.sh

FEEDS="$GLUON_SITE_FEEDS $GLUON_FEEDS"

rm -rf openwrt/tmp
rm -rf openwrt/feeds
rm -rf openwrt/package/feeds

(
	echo 'src-link gluon_base ../../package'
	for feed in $FEEDS; do
		echo "src-link $feed ../../packages/$feed"
	done
) > openwrt/feeds.conf

openwrt/scripts/feeds update -a
openwrt/scripts/feeds install -a
