local uci = require('simple-uci').cursor()

local site = require 'gluon.site'
local util = require 'gluon.util'
local vpn_core = require 'gluon.mesh-vpn'

local M = {}

function M.public_key()
	local key = util.trim(util.exec("/lib/gluon/mesh-vpn/wireguard_pubkey.sh"))

	if key == '' then
		key = nil
	end

	return key
end

function M.enable(val)
	uci:set('network', 'wg_mesh', 'disabled', not val)
	uci:save('network')
end

function M.active()
	return site.mesh_vpn.wireguard() ~= nil
end

function M.set_limit(ingress_limit, egress_limit)
	-- TODO: Test that limiting this via simple-tc here is correct!
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

function M.mtu()
	return site.mesh_vpn.wireguard.mtu()
end

return M
