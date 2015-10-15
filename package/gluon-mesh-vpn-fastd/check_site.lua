need_string_array('fastd_mesh_vpn.methods')
need_number('fastd_mesh_vpn.mtu')
need_boolean('fastd_mesh_vpn.enabled', false)
need_boolean('fastd_mesh_vpn.configurable', false)


local function check_peer(prefix)
  return function(k, _)
    assert_uci_name(k)

    local table = string.format('%s[%q].', prefix, k)

    need_string(table .. 'key')
    need_string_array(table .. 'remotes')
  end
end

local function check_group(prefix)
  return function(k, _)
    assert_uci_name(k)

    local table = string.format('%s[%q].', prefix, k)

    need_number(table .. 'limit', false)
    need_table(table .. 'peers', check_peer(table .. 'peers'), false)
    need_table(table .. 'groups', check_group(table .. 'groups'), false)
  end
end

need_table('fastd_mesh_vpn.groups', check_group('fastd_mesh_vpn.groups'))


if need_table('fastd_mesh_vpn.bandwidth_limit', nil, false) then
  need_boolean('fastd_mesh_vpn.bandwidth_limit.enabled', false)
  need_number('fastd_mesh_vpn.bandwidth_limit.ingress', false)
  need_number('fastd_mesh_vpn.bandwidth_limit.egress', false)
end
