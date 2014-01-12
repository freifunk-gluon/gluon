#!/bin/sh

if [ -f /lib/functions/jshn.sh ]; then
	. /lib/functions/jshn.sh
elif [ -f /usr/share/libubox/jshn.sh ]; then
	. /usr/share/libubox/jshn.sh
else
	echo "Error: jshn.sh not found!"
	exit 1
fi

[ -z "$ALFRED_DATA_TYPE" ] && ALFRED_DATA_TYPE=158

set -e

json_init
json_add_string "name" "$(uci get 'system.@system[0].hostname')"
if [ "$(uci get 'system.@system[0].share_location')" = 1 ]; then
	json_add_string "location" "$(uci get 'system.@system[0].latitude') $(uci get 'system.@system[0].longitude')"
fi

json_dump | tr -d '\n' | alfred -s "$ALFRED_DATA_TYPE"
