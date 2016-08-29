#!/bin/sh

. /lib/functions.sh
. ../netifd-proto.sh
init_proto "$@"

proto_gluon_mesh_init_config() {
	proto_config_add_boolean fixed_mtu
	proto_config_add_boolean transitive
}

proto_gluon_mesh_setup() {
	export CONFIG="$1"
	export IFNAME="$2"

	local fixed_mtu transitive
	json_get_vars fixed_mtu transitive

	export FIXED_MTU="$fixed_mtu"
	export TRANSITIVE="$transitive"

	for script in /lib/gluon/core/mesh/setup.d/*; do
	        [ ! -x "$script" ] || "$script"
	done

        proto_init_update "$IFNAME" 1
        proto_send_update "$CONFIG"
}

proto_gluon_mesh_teardown() {
	export CONFIG="$1"
	export IFNAME="$2"

	for script in /lib/gluon/core/mesh/teardown.d/*; do
	        [ ! -x "$script" ] || "$script"
	done
}

add_protocol gluon_mesh
