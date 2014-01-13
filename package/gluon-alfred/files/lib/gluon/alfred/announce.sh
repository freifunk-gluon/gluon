#!/bin/sh

if [ -f /lib/functions/jshn.sh ]; then
	. /lib/functions/jshn.sh
elif [ -f /usr/share/libubox/jshn.sh ]; then
	. /usr/share/libubox/jshn.sh
else
	echo "Error: jshn.sh not found!"
	exit 1
fi

. /lib/gluon/functions/model.sh
. /lib/gluon/functions/sysconfig.sh

[ -z "$ALFRED_DATA_TYPE" ] && ALFRED_DATA_TYPE=158
[ -z "$NET_IF" ] && NET_IF=br-client

set -e

json_init
json_add_string "name" "$(uci get 'system.@system[0].hostname')"
if [ "$(uci -q get 'system.@system[0].share_location')" = 1 ]; then
	json_add_object "location"
		json_add_double "latitude" "$(uci get 'system.@system[0].latitude')"
		json_add_double "longitude" "$(uci get 'system.@system[0].longitude')"
	json_close_object # location
fi
json_add_object "software"
	json_add_string "firmware" "gluon $(cat /lib/gluon/release)"
	if [ -x /usr/sbin/autoupdater ]; then
	json_add_object "autoupdater"
		json_add_string "branch" "$(uci -q get autoupdater.settings.branch)"
		json_add_boolean "enabled" "$(uci -q get autoupdater.settings.enabled)"
	json_close_object # autoupdater
	fi
json_close_object # software
json_add_object "hardware"
	json_add_string "model" "$(get_model)"
json_close_object # hardware
json_add_object "network"
	json_add_string "mac"   "$(sysconfig primary_mac)"
	json_add_array "addresses"
		for addr in $(ip -o -6 addr show dev "$NET_IF" | grep -oE 'inet6 [0-9a-fA-F:]+' | cut -d' ' -f2); do
			json_add_string "" "$addr"
		done
	json_close_array # adresses
json_close_object # network

json_dump | tr -d '\n' | alfred -s "$ALFRED_DATA_TYPE"
