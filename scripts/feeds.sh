#!/bin/sh

set -e

. scripts/modules.sh

(
	echo 'src-link gluon ../../package'
	for feed in $GLUON_SITE_FEEDS $GLUON_FEEDS; do
		echo "src-link packages_$feed ../../packages/$feed"
	done
) > lede/feeds.conf

rm -rf lede/feeds
rm -rf lede/package/feeds

lede/scripts/feeds update -a
lede/scripts/feeds install -a
