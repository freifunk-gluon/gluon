#!/bin/sh

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

proto_gluon_bat0_renew() {
	local config="$1"

	lock /var/lock/gluon_bat0.lock

	local ifdump="$(ubus call network.interface dump)"

	echo "$ifdump" | jsonfilter \
		-e "@.interface[@.proto='gluon_mesh' && @.up=true]['device','data']" \
	| while read dev; do
		read data

		echo bat0 > "/sys/class/net/$dev/batman_adv/mesh_iface"

		! [ "$(echo "$data" | jsonfilter -e "@.transitive")" = 'true' ]
		transitive=$?

		(echo "$transitive" > "/sys/class/net/$dev/batman_adv/no_rebroadcast") 2>/dev/null
	done

	lock -u /var/lock/gluon_bat0.lock
}

proto_gluon_bat0_setup() {
	local config="$1"

	local routing_algo=$(lookup_site 'mesh.batman_adv.routing_algo' 'BATMAN_IV')

	local gw_mode
	json_get_vars gw_mode

	batctl routing_algo "$routing_algo"
	batctl interface create

	batctl orig_interval 5000
	batctl hop_penalty 15
	batctl multicast_mode 0

	case "$gw_mode" in
		server)
			batctl gw_mode "server"
		;;
		client)
			local gw_sel_class="$(lookup_site 'mesh.batman_adv.gw_sel_class')"
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


	local primary0_mac="$(lua -e 'print(require("gluon.util").generate_mac(3))')"

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
