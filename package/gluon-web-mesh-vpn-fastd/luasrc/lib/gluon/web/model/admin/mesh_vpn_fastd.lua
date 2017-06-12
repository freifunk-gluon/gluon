local uci = require("simple-uci").cursor()
local util = gluon.web.util

local f = Form(translate('Mesh VPN'))

local s = f:section(Section)

local mode = s:option(Value, 'mode')
mode.template = "gluon/model/mesh-vpn-fastd"

local methods = uci:get('fastd', 'mesh_vpn', 'method')
if util.contains(methods, 'null') then
	mode.default = 'performance'
else
	mode.default = 'security'
end

function mode:write(data)
	local site = require 'gluon.site_config'

	local methods = {}
	if data == 'performance' then
		table.insert(methods, 'null')
	end

	for _, method in ipairs(site.mesh_vpn.fastd.methods) do
		if method ~= 'null' then
			table.insert(methods, method)
		end
	end

	uci:set('fastd', 'mesh_vpn', 'method', methods)

	uci:save('fastd')
	uci:commit('fastd')
end

return f
