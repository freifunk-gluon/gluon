#!/bin/sh

# shellcheck disable=SC1091,SC2034

INCLUDE_ONLY=1
. /lib/netifd/proto/wireguard.sh

ensure_key_is_generated wg_mesh
uci get "network.wg_mesh.private_key" | /usr/bin/wg pubkey
