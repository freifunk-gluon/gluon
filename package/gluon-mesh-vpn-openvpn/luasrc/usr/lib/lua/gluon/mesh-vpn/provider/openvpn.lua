local uci = require('simple-uci').cursor()

local site = require 'gluon.site'
local vpn_core = require 'gluon.mesh-vpn'

local M = {}

function M.public_key()
	return nil
end

function M.enable(val)
	uci:set('openvpn', 'mesh_vpn', 'enabled', val)
	uci:save('openvpn')
end

function M.active()
	return site.mesh_vpn.openvpn() ~= nil
end

function M.set_limit(ingress_limit, egress_limit)
	uci:delete('simple-tc', 'mesh_vpn')
	if ingress_limit ~= nil and egress_limit ~= nil then
		uci:section('simple-tc', 'interface', 'mesh_vpn', {
			ifname = vpn_core.get_interface(),
			enabled = true,
			limit_egress = egress_limit,
			limit_ingress = ingress_limit,
		})
	end

	uci:save('simple-tc')
end

return M
