#!/bin/sh

. /lib/functions.sh
. ../netifd-proto.sh
init_proto "$@"

proto_gluon_mesh_init_config() {
	proto_config_add_boolean fixed_mtu
	proto_config_add_boolean transitive
	proto_config_add_string ipaddr
	proto_config_add_string ip6addr
}

proto_gluon_mesh_setup() {
	export CONFIG="$1"
	export IFNAME="$2"

	local fixed_mtu transitive ipaddr ip6addr
	json_get_vars fixed_mtu transitive ipaddr ip6addr

	export FIXED_MTU="${fixed_mtu:-0}"
	export TRANSITIVE="${transitive:-0}"

	for script in /lib/gluon/core/mesh/setup.d/*; do
		[ ! -x "$script" ] || "$script"
	done

	proto_init_update "$IFNAME" 1

	proto_add_data
	json_add_boolean fixed_mtu "$FIXED_MTU"
	json_add_boolean transitive "$TRANSITIVE"
	if [ ! -z "$ipaddr" ]; then
		json_add_string ipaddr "$ipaddr"
	fi
	if [ ! -z "$ip6addr" ]; then
		json_add_string ip6addr "$ip6addr"
	fi
	[ "$IFNAME" != 'br-wan' ] && json_add_string zone 'mesh'
	proto_close_data
	proto_send_update "$CONFIG"

	if [ ! -z "$ipaddr" ]; then
		ip addr add "$ipaddr" dev "$IFNAME"
	fi
	if [ ! -z "$ip6addr" ]; then
		ip addr add "$ip6addr" dev "$IFNAME"
	fi

	for script in /lib/gluon/core/mesh/post-setup.d/*; do
		[ ! -x "$script" ] || "$script"
	done
}

proto_gluon_mesh_teardown() {
	export CONFIG="$1"
	export IFNAME="$2"

	local ipaddr ip6addr
	json_get_vars ipaddr ip6addr

	if [ ! -z "$ipaddr" ]; then
		ip addr del "$ipaddr" dev "$IFNAME"
	fi
	if [ ! -z "$ip6addr" ]; then
		ip addr del "$ip6addr" dev "$IFNAME"
	fi

	for script in /lib/gluon/core/mesh/teardown.d/*; do
		[ ! -x "$script" ] || "$script"
	done
}

add_protocol gluon_mesh
