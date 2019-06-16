local uci = require("simple-uci").cursor()
local util = require 'gluon.util'

local f = Form(translate('Mesh VPN'))

local s = f:section(Section)

local mode = s:option(Value, 'mode')
mode.package = "gluon-web-mesh-vpn-fastd"
mode.template = "mesh-vpn-fastd"

local methods = uci:get('fastd', 'mesh_vpn', 'method')
if util.contains(methods, 'null') then
	-- performance mode will only be used as default, if it is present in site.mesh_vpn.fastd.methods
	mode.default = 'performance'
else
	mode.default = 'security'
end

function mode:write(data)
	local site = require 'gluon.site'

	-- methods will be recreated and filled with the original values from site.mesh_vpn.fastd.methods
	-- if performance mode was selected, and the method 'null' was not present in the original table, it will be added
	local methods = {}
	if data == 'performance' then
		table.insert(methods, 'null')
	end

	for _, method in ipairs(site.mesh_vpn.fastd.methods()) do
		if method ~= 'null' then
			table.insert(methods, method)
		end
	end

	uci:set('fastd', 'mesh_vpn', 'method', methods)

	uci:save('fastd')
	uci:commit('fastd')
end

return f
