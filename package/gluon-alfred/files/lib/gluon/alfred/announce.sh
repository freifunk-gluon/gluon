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

# set defaults
[ -z "$ALFRED_DATA_TYPE" ] && ALFRED_DATA_TYPE=158
[ -z "$NET_IF" ] && NET_IF=br-client

set -e

json_init
json_add_string "hostname" "$(uci get 'system.@system[0].hostname')"

if [ "$(uci -q get 'gluon-node-info.@location[0].share_location')" = 1 ]; then
json_add_object "location"
	json_add_double "latitude" "$(uci get 'gluon-node-info.@location[0].latitude')"
	json_add_double "longitude" "$(uci get 'gluon-node-info.@location[0].longitude')"
json_close_object # location
fi

if [ -n "$(uci -q get 'gluon-node-info.@owner[0].contact')" ]; then
json_add_object "owner"
	json_add_string "contact" "$(uci get 'gluon-node-info.@owner[0].contact')"
json_close_object # owner
fi

json_add_object "software"
	json_add_object "firmware"
		json_add_string "base" "gluon-$(cat /lib/gluon/gluon-version)"
		json_add_string "release" "$(cat /lib/gluon/release)"
	json_close_object # firmware

	if [ -x /usr/sbin/autoupdater ]; then
	json_add_object "autoupdater"
		json_add_string "branch" "$(uci -q get autoupdater.settings.branch)"
		json_add_boolean "enabled" "$(uci -q get autoupdater.settings.enabled)"
	json_close_object # autoupdater
	fi

	if [ -x /usr/bin/fastd ]; then
	json_add_object "fastd"
		json_add_string "version" "$(fastd -v | cut -d' ' -f2)"
		json_add_boolean "enabled" "$(uci -q get fastd.mesh_vpn.enabled)"
	json_close_object # fastd
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

	GATEWAY="$(batctl -m bat0 gateways | awk '/^=>/ { print $2 }')"
	[ -z "$GATEWAY" ] || json_add_string "gateway" "$GATEWAY"
json_close_object # network

json_add_object "statistics"
	json_add_int "uptime" "$(cut -d' ' -f1 /proc/uptime)"
	json_add_double "loadavg" "$(cut -d' ' -f1 /proc/loadavg)"
	json_add_object "traffic"
		TRAFFIC="$(ethtool -S bat0 | sed -e 's/^ *//')"
		for class in rx tx forward mgmt_rx mgmt_tx; do
		json_add_object "$class"
			json_add_int "bytes" "$(echo "$TRAFFIC" | awk -F': ' "/^${class}_bytes:/ { print \$2 }")"
			json_add_int "packets" "$(echo "$TRAFFIC" | awk -F': ' "/^${class}:/ { print \$2 }")"
			if [ "$class" = "tx" ]; then
				json_add_int "dropped" "$(echo "$TRAFFIC" | awk -F': ' "/^${class}_dropped:/ { print \$2 }")"
			fi
		json_close_object # $class
		done
	json_close_object # traffic
json_close_object # statistics

json_dump | tr -d '\n' | alfred -s "$ALFRED_DATA_TYPE"
