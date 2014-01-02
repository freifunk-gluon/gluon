. "$1"/modules

GLUON_MODULES=openwrt

for feed in $GLUON_FEEDS; do
	GLUON_MODULES="$GLUON_MODULES packages/$feed"
done
