need_boolean('mesh_vpn.enabled', false)
need_number('mesh_vpn.mtu')

if need_table('mesh_vpn.bandwidth_limit', nil, false) then
	need_boolean('mesh_vpn.bandwidth_limit.enabled', false)
	need_number('mesh_vpn.bandwidth_limit.ingress', false)
	need_number('mesh_vpn.bandwidth_limit.egress', false)
end
