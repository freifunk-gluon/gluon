#!/bin/sh
# Copyright 2016-2017 Christof Schulze <christof@christofschulze.com>
# Licensed to the public under the Apache License 2.0.

. /lib/functions.sh
. ../netifd-proto.sh
init_proto "$@"

proto_gluon_wireguard_init_config() {
	no_device=1
	available=1
	renew_handler=1
}

proto_gluon_wireguard_renew() {
	local config="$1"
	echo "wireguard RENEW: $*"
	ifdown "$config"
	ifup "$config"
}

proto_gluon_wireguard_setup() {
	local config="$1"
	ifname="$(uci get "network.$config.ifname")" # we need uci here because nodevice=1 means the device is not part of the ubus structure

	local peer_limit=$(gluon-show-site |jsonfilter -e $.mesh_vpn.wireguard.groups.backbone.limit)
	if [[ $(wg show all latest-handshakes |wc -l) -ge "$peer_limit" ]]; then
		echo "not establishing another connection, we already have  $peer_limit connections." >&2
		ip link del "$ifname"
		ifdown "$config"
		exit 1
	fi

	(
		flock -n 9

		if [[ $(uci get gluon.mesh_vpn.enabled) -eq 1 ]]; then
			ip link del "$ifname"
			ip link add dev "$ifname" type wireguard
			ip link set mtu "$(gluon-show-site | jsonfilter -e $.mesh_vpn.mtu)" dev "$ifname"
			ip link set multicast on dev "$ifname"

			mkdir -p /var/gluon/mesh-vpn-wireguard
			secretfile=/var/gluon/mesh-vpn-wireguard/secret
			secret=$(gluon-mesh-vpn-wireguard-get-or-create-secret)

			echo "$secret" > "$secretfile"
			pubkey=$(echo "$secret"| wg pubkey)

			gwname=${config##*_}
			peer=${gwname%?}

			peer_config=$(gluon-show-site |jsonfilter -e "$.mesh_vpn.wireguard.groups.backbone.peers.$peer")
			remote=$(jsonfilter -s "$peer_config" -e "$.remote")
			brokerport=$(jsonfilter -s "$peer_config" -e "$.broker_port")
			peer_key=$(jsonfilter -s "$peer_config" -e "$.key")
			remoteport=$(/usr/bin/wg-broker-client "$ifname" "$pubkey" "$remote" "$brokerport")

			if [[ "$remoteport" == "FULL" ]]; then
				echo "wireguard server $remote is not accepting additional connections. Closing this interface" >&2
				ip link del "$ifname"
				exit 1
			elif [[ "$remoteport" == "ERROR" ]]; then
				echo "error when setting up wireguard connection for $ifname" >&2
				ip link del "$ifname"
				exit 1
			elif [[ -z "$remoteport" ]]; then
				echo "error when setting up wireguard connection for $ifname - no response from broker: $remote" >&2
				ip link del "$ifname"
				exit 1
			fi

			gluon-wan wg set "$ifname" private-key "$secretfile" peer "$peer_key" endpoint "$remote:$remoteport" allowed-ips ::/0 persistent-keepalive 25

			ip link set dev "$ifname" up
			ip -6 route add fe80::/64 dev "$ifname" proto kernel metric 256 pref medium table local

			proto_init_update "$ifname" 1
			proto_send_update "$config"
		fi
	) 9>"/var/lock/wireguard_proto_${ifname}.lock" || ifdown "$config"
}

proto_gluon_wireguard_teardown() {
	local config="$1"
	echo teardown config: "$config"
	ifname=$(uci get "network.$config.ifname") # we need uci here because nodevice=1 means the device is not part of the ubus structure

	ip link del "$ifname"
}

[[ -n "$INCLUDE_ONLY" ]] || {
	add_protocol gluon_wireguard
}
