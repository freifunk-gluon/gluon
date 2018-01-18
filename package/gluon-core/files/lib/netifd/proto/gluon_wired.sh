#!/bin/sh

. /lib/functions.sh
. ../netifd-proto.sh
init_proto "$@"

proto_gluon_wired_init_config() {
        proto_config_add_boolean transitive
        proto_config_add_int index
        proto_config_add_boolean legacy
}

xor2() {
        echo -n "${1:0:1}"
        echo -n "${1:1:1}" | tr '0123456789abcdef' '23016745ab89efcd'
}

interface_linklocal() {
        local macaddr="$(ubus call network.device status '{"name": "'"$1"'"}' | jsonfilter -e '@.macaddr')"
        local oldIFS="$IFS"; IFS=':'; set -- $macaddr; IFS="$oldIFS"

        echo "fe80::$(xor2 "$1")$2:$3ff:fe$4:$5$6"
}

proto_gluon_wired_setup() {
        local config="$1"
        local ifname="$2"

        local meshif="$config"

        local transitive index legacy
        json_get_vars transitive index legacy

        proto_init_update "$ifname" 1
        proto_send_update "$config"

        if [ "${legacy:-0}" -eq 0 ]; then
                meshif="vx_$config"

                json_init
                json_add_string name "$meshif"
                [ -n "$index" ] && json_add_string macaddr "$(lua -lgluon.util -e "print(gluon.util.generate_mac($index))")"
                json_add_string proto 'vxlan6'
                json_add_string tunlink "$config"
                json_add_string ip6addr "$(interface_linklocal "$ifname")"
                json_add_string peer6addr 'ff02::15c'
                json_add_int vid "$(lua -lgluon.util -e 'print(tonumber(gluon.util.domain_seed_bytes("gluon-mesh-vxlan", 3), 16))')"
                json_close_object
                ubus call network add_dynamic "$(json_dump)"
        fi

        json_init
        json_add_string name "${config}_mesh"
        json_add_string ifname "@${meshif}"
        json_add_string proto 'gluon_mesh'
        json_add_boolean fixed_mtu 1
        [ -n "$transitive" ] && json_add_boolean transitive "$transitive"
        json_close_object
        ubus call network add_dynamic "$(json_dump)"
}

proto_gluon_wired_teardown() {
        local config="$1"

        proto_init_update "*" 0
        proto_send_update "$config"
}

add_protocol gluon_wired
