local uci = require('simple-uci').cursor()

local site = require 'gluon.site'
local util = require 'gluon.util'
local vpn_core = require 'gluon.mesh-vpn'

local M = {}

function M.public_key()
	return util.trim(util.exec('/etc/init.d/fastd show_key mesh_vpn'))
end

function M.enable(val)
	uci:set('fastd', 'mesh_vpn', 'enabled', val)
	uci:save('fastd')
end

function M.active()
	return site.mesh_vpn.fastd() ~= nil
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
