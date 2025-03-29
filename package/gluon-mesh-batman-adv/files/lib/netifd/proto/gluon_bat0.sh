#!/bin/sh

# shellcheck disable=SC1091,SC2034

. /lib/functions.sh
. ../netifd-proto.sh
init_proto "$@"

proto_gluon_bat0_init_config() {
	no_device=1
	available=1
	renew_handler=1

	proto_config_add_string 'gw_mode'
}

lookup_site() {
	local path="$1" default="$2"
	lua -e "print(require('gluon.site').$path('$default'))"
}

lookup_uci() {
	local path="$1" default="$2"
	uci -q get "$path" || echo "$default"
}

proto_gluon_bat0_renew() {
	local config="$1"

	lock /var/lock/gluon_bat0.lock

	ubus call network.interface dump | jsonfilter \
		-e "@.interface[@.proto='gluon_mesh' && @.up=true].device" \
	| xargs -r -n 1 batctl interface add

	lock -u /var/lock/gluon_bat0.lock
}

proto_gluon_bat0_setup() {
	local config="$1"

	local routing_algo
	routing_algo="$(lookup_site 'mesh.batman_adv.routing_algo' 'BATMAN_IV')"

	local gw_mode
	json_get_vars gw_mode

	batctl routing_algo "$routing_algo"
	batctl interface create

	batctl orig_interval 5000
	batctl hop_penalty "$(lookup_uci 'gluon.mesh_batman_adv.hop_penalty' 15)"
	batctl noflood_mark 0x4/0x4

	case "$gw_mode" in
		server)
			batctl gw_mode "server"
		;;
		client)
			local gw_sel_class
			gw_sel_class="$(lookup_site 'mesh.batman_adv.gw_sel_class')"
			if [ -n "$gw_sel_class" ]; then
				batctl gw_mode "client" "$gw_sel_class"
			else
				batctl gw_mode "client"
			fi
		;;
		*)
			batctl gw_mode "off"
		;;
	esac


	local primary0_mac
	primary0_mac="$(lua -e 'print(require("gluon.util").generate_mac(3))')"

	ip link add primary0 type dummy
	echo 1 > /proc/sys/net/ipv6/conf/primary0/disable_ipv6
	ip link set primary0 address "$primary0_mac" mtu 1532 up

	batctl interface add primary0

	proto_init_update primary0 1
	proto_send_update "$config"

	proto_gluon_bat0_renew "$1"
}

proto_gluon_bat0_teardown() {
	local config="$1"

	batctl interface destroy
	ip link del primary0
}

add_protocol gluon_bat0
