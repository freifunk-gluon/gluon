. "$GLUONDIR"/modules
[ ! -f "$GLUON_SITEDIR"/modules ] || . "$GLUON_SITEDIR"/modules

GLUON_MODULES=openwrt

for feed in $GLUON_SITE_FEEDS $GLUON_FEEDS; do
	GLUON_MODULES="$GLUON_MODULES packages/$feed"
done
