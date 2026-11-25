local uci = require('simple-uci').cursor()

local site = require 'gluon.site'
local util = require 'gluon.util'
local vpn_core = require 'gluon.mesh-vpn'

local M = {}

function M.public_key()
	local key = util.trim(util.exec('/etc/init.d/fastd show_key mesh_vpn'))

	if key == '' then
		key = nil
	end

	return key
end

function M.enable(val)
	uci:set('fastd', 'mesh_vpn', 'enabled', val)
	uci:save('fastd')
end

function M.active()
	return site.mesh_vpn.fastd() ~= nil
end

function M.set_limit(ingress_limit, egress_limit)
	vpn_core.set_limit(ingress_limit, egress_limit)
end

function M.mtu()
	return site.mesh_vpn.fastd.mtu()
end

function M.pubkey_privacy()
	return site.mesh_vpn.pubkey_privacy(true)
end

return M
