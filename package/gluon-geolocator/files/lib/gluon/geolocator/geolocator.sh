#!/bin/sh

LOC="gluon-node-info.@location[0]"
GLC="geolocator.settings"
[ "$(uci get "${GLC}".auto_location)" -eq 0 ] && exit 0

PID_PART="/var/run/geolocator.pid"
TIME_STAMP="/tmp/geolocator_timestamp"

if [ -f $PID_PART ]; then
	echo "The geolocator is still running"; exit 0;
else touch $PID_PART; fi

Clean_pid() { [ -f $PID_PART ] && rm $PID_PART; exit 0; }

# get position
Get_geolocation_info() {
	# Get list of BSSID there should ignored
	blacklist_bssid=""
	for bl_bssid in $(uci get geolocator.settings.blacklist); do
		blacklist_bssid="$blacklist_bssid,$( echo "$bl_bssid" | awk '{print toupper($0)}' )"
	done
	[ -z "$blacklist_bssid" ] || blacklist_bssid="${blacklist_bssid:1}"
	# Get list of BSSID without blacklisted and redundancy entrys.
	scaned_bssid=""
	for iface in $(uci show wireless | grep -E "ifname='" | awk -F\' '{print $2}'); do
		for line in $(iw "$iface" scan dump | grep -Eo "^BSS .{0,17}" | awk '{ print toupper($2)}' | sed 's/\://g'); do
			if ! printf -- '%s' "$scaned_bssid" | grep -Eq -- "$line" && ! printf -- '%s' "$blacklist_bssid" | grep -Eq -- "$line"; then
				scaned_bssid="${scaned_bssid},${line}"
			fi
		done
	done
	[ -z "$scaned_bssid" ] && { echo "no surrounded BSSIDs found."; return 1; }
	scaned_bssid="${scaned_bssid:1}"
	TMP_GEO="/tmp/lwtrace_out"
	(wget -O $TMP_GEO http://openwifi.su/api/v1/bssids/"$scaned_bssid") & subpid=$!
	(sleep 15 && kill -9 $subpid > /dev/null 2>&1) & waitpid=$!
	wait $subpid
	kill -INT $waitpid >/dev/null 2>&1
	[ -f $TMP_GEO ] || { echo "connection failed."; return 1; }
	FILTER_REQUEST=$(< $TMP_GEO sed -e 's/[{}]/''/g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}')
	rm $TMP_GEO
	echo "$FILTER_REQUEST" | grep -E "(\"lat\":[0-9]+.[0-9]*|\"lon\":[0-9]+.[0-9]*)" >> /dev/null || {
		echo "lwtrace doesn't gif a location"; return 1
	}
	LAT=$(echo "$FILTER_REQUEST" | grep lat | awk -F":" '{print $2}')
	LON=$(echo "$FILTER_REQUEST" | grep lon | awk -F":" '{print $2}')
	[ -z "${LAT// }" ] && { echo "no latitude"; return 1; }
	[ -z "${LON// }" ] && { echo "no longitude"; return 1; }
	return 0
}

#check if interval over or not exist
if [ ! -f $TIME_STAMP ] || [ $(( $(date +%s) - $(cat $TIME_STAMP) )) -gt $(( $(uci get "${GLC}".refresh_interval) * 60 )) ]; then
	Get_geolocation_info
	[ $? -eq 1 ] && Clean_pid
	#ceck if static location true or not
	[ "$(uci get "${GLC}".static_location)" -eq 0 ] && {
		uci set "${LOC}".latitude="$LAT"
		uci set "${LOC}".longitude="$LON"
		uci commit gluon-node-info
	}
	date +%s > $TIME_STAMP
fi
Clean_pid
