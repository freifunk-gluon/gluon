local uci = require('simple-uci').cursor()

local site = require 'gluon.site'
local util = require 'gluon.util'
local vpn_core = require 'gluon.mesh-vpn'

local unistd = require 'posix.unistd'

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

local function set_limit_simple_tc(ingress_limit, egress_limit)
	uci:section('simple-tc', 'interface', 'mesh_vpn', {
		ifname = vpn_core.get_interface(),
		enabled = true,
		limit_egress = egress_limit,
		limit_ingress = ingress_limit,
	})
end

local function set_limit_sqm(ingress_limit, egress_limit)
	uci:section('sqm', 'queue', 'mesh_vpn', {
		interface = vpn_core.get_interface(),
		enabled = true,
		upload = egress_limit,
		download = ingress_limit,
		qdisc = 'cake',
		script = 'piece_of_cake.qos',
		debug_logging = '0',
		verbosity = '5',
	})
end

local function sqm_available()
	return unistd.access('/lib/gluon/mesh-vpn/sqm')
end

function M.set_limit(ingress_limit, egress_limit)
	uci:delete('simple-tc', 'mesh_vpn')
	uci:delete('sqm', 'mesh_vpn')

	if ingress_limit ~= nil and egress_limit ~= nil then
		if sqm_available() and util.get_mem_total() > 200*1024 then
			set_limit_sqm(ingress_limit, egress_limit)
		else
			set_limit_simple_tc(ingress_limit, egress_limit)
		end
	end

	uci:save('simple-tc')
	uci:save('sqm')
end

function M.mtu()
	return site.mesh_vpn.fastd.mtu()
end

function M.pubkey_privacy()
	return site.mesh_vpn.pubkey_privacy(true)
end

return M
