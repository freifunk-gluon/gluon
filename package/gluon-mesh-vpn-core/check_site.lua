need_boolean(in_site('mesh_vpn.enabled'), false)
need_number('mesh_vpn.mtu')

if need_table(in_site('mesh_vpn.bandwidth_limit'), nil, false) then
	need_boolean(in_site('mesh_vpn.bandwidth_limit.enabled'), false)
	need_number(in_site('mesh_vpn.bandwidth_limit.ingress'), false)
	need_number(in_site('mesh_vpn.bandwidth_limit.egress'), false)
end
