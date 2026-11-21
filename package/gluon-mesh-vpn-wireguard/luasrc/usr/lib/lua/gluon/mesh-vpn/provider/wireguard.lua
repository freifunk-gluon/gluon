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
	vpn_core.set_limit(ingress_limit, egress_limit)
end

function M.mtu()
	return site.mesh_vpn.wireguard.mtu()
end

function M.pubkey_privacy()
	-- WireGuard inherently doesn't leak the pubkey to third parties upon initiating connections.
	return false
end

return M
