#!/bin/bash

set -e

. scripts/modules.sh
. scripts/default_feeds.sh


rm -rf openwrt/tmp
rm -rf openwrt/feeds
rm -rf openwrt/package/feeds

(
	echo "$GLUON_BASE_FEEDS"
	for feed in $FEEDS; do
		echo "src-link $feed ../../packages/$feed"
	done
	for feed in $(echo "$DEFAULT_FEEDS" | grep -vxF "$FEEDS"); do
		echo "src-dummy $feed"
	done
) > openwrt/feeds.conf

openwrt/scripts/feeds update -a
openwrt/scripts/feeds install -a
