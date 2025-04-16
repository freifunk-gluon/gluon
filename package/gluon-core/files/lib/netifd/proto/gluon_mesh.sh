#!/bin/sh

# shellcheck disable=SC1091

. /lib/functions.sh
. ../netifd-proto.sh
init_proto "$@"

proto_gluon_mesh_init_config() {
	proto_config_add_boolean fixed_mtu
}

proto_gluon_mesh_setup() {
	export CONFIG="$1"
	export IFNAME="$2"

	local fixed_mtu
	json_get_vars fixed_mtu

	export FIXED_MTU="${fixed_mtu:-0}"

	for script in /lib/gluon/core/mesh/setup.d/*; do
		[ ! -x "$script" ] || "$script"
	done

	proto_init_update "$IFNAME" 1

	proto_add_data
	json_add_boolean fixed_mtu "$FIXED_MTU"
	[ "$IFNAME" != 'br-wan' ] && json_add_string zone 'mesh'
	proto_close_data
	proto_send_update "$CONFIG"

	for script in /lib/gluon/core/mesh/post-setup.d/*; do
		[ ! -x "$script" ] || "$script"
	done
}

proto_gluon_mesh_teardown() {
	export CONFIG="$1"
	export IFNAME="$2"

	for script in /lib/gluon/core/mesh/teardown.d/*; do
		[ ! -x "$script" ] || "$script"
	done
}

add_protocol gluon_mesh
