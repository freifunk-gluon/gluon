#!/bin/sh

. /lib/functions.sh
. ../netifd-proto.sh
init_proto "$@"

proto_static_deprecated_init_config() {
	renew_handler=1

	proto_config_add_string 'ip6addr:ip6addr'
}

proto_static_deprecated_setup() {
	local config="$1"
	local iface="$2"

	local ip6addr
	json_get_vars ip6addr

	proto_init_update "*" 1          
	proto_add_ipv6_address "$ip6addr" "" "0"
	proto_send_update "$config"
}

proto_static_deprecated_teardown() {
	local config="$1"
}

add_protocol static_deprecated

