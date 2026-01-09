need_boolean(in_site({'mesh_vpn', 'enabled'}), false)
need_boolean({'mesh_vpn', 'pubkey_privacy'}, false)

need_boolean(in_site({'mesh_vpn', 'bandwidth_limit', 'enabled'}), false)
need_number(in_site({'mesh_vpn', 'bandwidth_limit', 'ingress'}), false)
need_number(in_site({'mesh_vpn', 'bandwidth_limit', 'egress'}), false)
