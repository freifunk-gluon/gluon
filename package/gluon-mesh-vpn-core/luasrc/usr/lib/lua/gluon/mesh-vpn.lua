local uci = require('simple-uci').cursor()

local util = require 'gluon.util'

local unistd = require 'posix.unistd'

local M = {}

function M.enabled()
	return uci:get_bool('gluon', 'mesh_vpn', 'enabled')
end

function M.enable(val)
	return uci:set('gluon', 'mesh_vpn', 'enabled', val)
end

function M.get_interface()
	return 'mesh-vpn'
end

local function set_limit_simple_tc(ingress_limit, egress_limit)
	uci:section('simple-tc', 'interface', 'mesh_vpn', {
		ifname = M.get_interface(),
		enabled = true,
		limit_egress = egress_limit,
		limit_ingress = ingress_limit,
	})
end

local function set_limit_sqm(ingress_limit, egress_limit)
	uci:section('sqm', 'queue', 'mesh_vpn', {
		interface = M.get_interface(),
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
	return unistd.access('/lib/gluon/mesh-vpn/sqm') == 0
end

-- Applies the bandwidth limit (in kbit/s) to the mesh VPN interface.
-- CAKE (SQM) is used when gluon-mesh-vpn-sqm is installed and the device
-- has enough memory, simple-tc otherwise. nil limits remove the limit.
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

function M.get_provider(name)
	return require('gluon.mesh-vpn.provider.' .. name)
end

function M.get_provider_names()
	local out = {}

	for _, v in ipairs(util.glob('/lib/gluon/mesh-vpn/provider/*')) do
		table.insert(out, v:match('([^/]+)$'))
	end

	return out
end

function M.get_active_provider()
	-- Active provider is the provider in use
	-- by the currently active site / domain

	for _, name in ipairs(M.get_provider_names()) do
		local provider = M.get_provider(name)
		if provider.active() then
			return name, provider
		end
	end

	return nil, nil
end

function M.get_enabled_public_key()
	if M.enabled() ~= true then
		return nil
	end

	local _, active_vpn = M.get_active_provider()

	local pubkey
	if active_vpn ~= nil then
		if not active_vpn.pubkey_privacy() then
			pubkey = active_vpn.public_key()
		end
	end

	return pubkey
end

return M
