local uci = require('simple-uci').cursor()

local site = require 'gluon.site'
local vpn_core = require 'gluon.mesh-vpn'

local M = {}

function M.public_key()
	return nil
end

function M.enable(val)
	uci:set('tunneldigger', 'mesh_vpn', 'enabled', val)
	uci:save('tunneldigger')
end

function M.active()
	return site.mesh_vpn.tunneldigger() ~= nil
end

function M.set_limit(ingress_limit, egress_limit)
	if ingress_limit ~= nil then
		uci:set('tunneldigger', 'mesh_vpn', 'limit_bw_down', ingress_limit)
	else
		uci:delete('tunneldigger', 'mesh_vpn', 'limit_bw_down')
	end

	if egress_limit ~= nil then
		uci:section('simple-tc', 'interface', 'mesh_vpn', {
			ifname = vpn_core.get_interface(),
			enabled = true,
			limit_egress = egress_limit,
		})
	else
		uci:delete('simple-tc', 'mesh_vpn')
	end

	uci:save('tunneldigger')
	uci:save('simple-tc')
end

function M.mtu()
	return site.mesh_vpn.tunneldigger.mtu()
end

return M
