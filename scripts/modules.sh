. ./modules
[ ! -f "$GLUON_SITEDIR"/modules ] || . "$GLUON_SITEDIR"/modules

# shellcheck disable=SC2086
FEEDS="$(echo $GLUON_FEEDS $GLUON_SITE_FEEDS | tr ' ' '\n')"

GLUON_MODULES=openwrt

for feed in $FEEDS; do
	GLUON_MODULES="$GLUON_MODULES packages/$feed"
done
