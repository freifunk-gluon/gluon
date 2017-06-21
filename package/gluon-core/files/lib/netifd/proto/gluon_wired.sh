#!/bin/sh

. /lib/functions.sh
. ../netifd-proto.sh
init_proto "$@"

proto_gluon_wired_init_config() {
        proto_config_add_boolean transitive
}

proto_gluon_wired_setup() {
        local config="$1"
        local ifname="$2"

        local transitive
        json_get_vars transitive

        proto_init_update "$ifname" 1
        proto_send_update "$config"

        json_init
        json_add_string name "${config}_mesh"
        json_add_string ifname "@${config}"
        json_add_string proto 'gluon_mesh'
        json_add_boolean fixed_mtu 1
        [ -n "$transitive" ] && json_add_boolean transitive "$transitive"
        json_close_object
        ubus call network add_dynamic "$(json_dump)"
}

proto_gluon_wired_teardown() {
        export config="$1"

        proto_init_update "*" 0
        proto_send_update "$config"
}

add_protocol gluon_wired
