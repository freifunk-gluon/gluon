local f, s, o
local site = require 'gluon.site_config'
local uci = require("simple-uci").cursor()
local config = 'gluon-node-info'

-- where to read the configuration from
local role = uci:get(config, uci:get_first(config, "system"), "role")

f = Form(translate("Node role"))

s = f:section(Section, nil, translate(
	"If this node has a special role within the freifunk network you can specify this role here. "
	.. "Please find out about the available roles and their impact first. "
	.. "Only change the role if you know what you are doing."
))

o = s:option(ListValue, "role", translate("Role"))
o.default = role
for _, role in ipairs(site.roles.list) do
	o:value(role, translate('gluon-web-node-role:role:' .. role))
end

function o:write(data)
	uci:set(config, uci:get_first(config, "system"), "role", data)
	uci:commit(config)
end

return f
