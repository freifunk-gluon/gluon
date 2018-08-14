#!/bin/sh

. /lib/functions.sh
. ../netifd-proto.sh
init_proto "$@"

proto_gluon_bat0_init_config() {
	no_device=1
	available=1
	renew_handler=1
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

	local primary0_mac="$(lua -lgluon.util -e 'print(gluon.util.generate_mac(3))')"

	ip link add primary0 type dummy
	echo 1 > /proc/sys/net/ipv6/conf/primary0/disable_ipv6
	ip link set primary0 address "$primary0_mac" mtu 1532 up

	local routing_algo="$(uci -q get batman-adv.bat0.routing_algo || echo 'BATMAN_IV')"
	(echo "$routing_algo" >/sys/module/batman_adv/parameters/routing_algo) 2>/dev/null

	echo bat0 > /sys/class/net/primary0/batman_adv/mesh_iface

	proto_init_update primary0 1
	proto_send_update "$config"

	proto_gluon_bat0_renew "$1"
}

proto_gluon_bat0_teardown() {
	local config="$1"

	ip link del bat0
	ip link del primary0
}

add_protocol gluon_bat0
