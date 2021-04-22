local f, s, o
local site = require 'gluon.site'
local site_i18n = i18n 'gluon-site'
local uci = require("simple-uci").cursor()
local util = require 'gluon.util'
local config = 'gluon-node-info'

-- where to read the configuration from
local role = uci:get(config, uci:get_first(config, "system"), "role")

f = Form(translate("Node role"))

if not util.in_setup_mode() then
	f.submit = translate('Save & apply')
end

s = f:section(Section, nil, translate(
	"If this node has a special role within the mesh network you can specify this role here. "
	.. "Please find out about the available roles and their impact first. "
	.. "Only change the role if you know what you are doing."
))

o = s:option(ListValue, "role", translate("Role"))
o.default = role
for _, role_value in ipairs(site.roles.list()) do
	o:value(role_value, site_i18n.translate('gluon-web-node-role:role:' .. role_value))
end

function o:write(data)
	uci:set(config, uci:get_first(config, "system"), "role", data)
	uci:commit(config)

	if not util.in_setup_mode() then
		util.reconfigure_asynchronously()
	end
end

return f
