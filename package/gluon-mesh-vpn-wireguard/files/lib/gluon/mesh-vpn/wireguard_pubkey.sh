#!/bin/sh

private_key="$(uci -q get network.wg_mesh.private_key)"

if [ "$private_key" = "generate" ] || [ -z "$private_key" ]; then
	private_key="$(/usr/bin/wg genkey)"
	uci -q set network.wg_mesh.private_key="$private_key" &&
		uci -q commit network
fi

echo "$private_key" | /usr/bin/wg pubkey
