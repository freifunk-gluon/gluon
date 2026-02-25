#!/bin/sh

[ "$ACTION" = "add" ] || exit 0

PHYNBR=${DEVPATH##*/phy}

[ -n "$PHYNBR" ] || exit 0

[ -e "/sys/kernel/debug/ieee80211/phy${PHYNBR}/mt76/twt_stats" ] || exit 0

echo 0 > "/sys/kernel/debug/ieee80211/phy${PHYNBR}/aql_enable"
