#!/bin/bash

set -e

. scripts/modules.sh

FEEDS="$GLUON_SITE_FEEDS $GLUON_FEEDS"

(
	cat lede/feeds.conf.default
	echo 'src-link gluon ../../package'
	for feed in $FEEDS; do
		echo "src-link packages_$feed ../../packages/$feed"
	done
) > lede/feeds.conf

rm -rf lede/tmp
rm -rf lede/feeds
rm -rf lede/package/feeds

mkdir -p lede/overlay
rm -f lede/overlay/gluon
ln -s ../../overlay lede/overlay/gluon

lede/scripts/feeds update 'gluon'
for feed in $FEEDS; do
	lede/scripts/feeds update "packages_$feed"
done

lede/scripts/feeds install -a
