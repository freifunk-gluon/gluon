. "$1"/modules
[ ! -f "$1"/site/modules ] || . "$1"/site/modules

GLUON_MODULES=openwrt

for feed in $GLUON_SITE_FEEDS $GLUON_FEEDS; do
	GLUON_MODULES="$GLUON_MODULES packages/$feed"
done
