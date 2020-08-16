local uci = require('simple-uci').cursor()

local util = require 'gluon.util'

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

return M
