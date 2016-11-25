need_number('tunneldigger_mesh_vpn.mtu')
need_boolean('tunneldigger_mesh_vpn.enabled', false)
need_string_array('tunneldigger_mesh_vpn.brokers')

if need_table('tunneldigger_mesh_vpn.bandwidth_limit', nil, false) then
  need_boolean('tunneldigger_mesh_vpn.bandwidth_limit.enabled', false)
  need_number('tunneldigger_mesh_vpn.bandwidth_limit.ingress', false)
  need_number('tunneldigger_mesh_vpn.bandwidth_limit.egress', false)
end
