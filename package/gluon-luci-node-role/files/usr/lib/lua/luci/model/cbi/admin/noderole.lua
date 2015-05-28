local f, s, o
local site = require 'gluon.site_config'
local i18n = require "luci.i18n"
local uci = luci.model.uci.cursor()
local config = 'gluon-node-info'

-- where to read the configuration from
local role = uci:get(config, uci:get_first(config, "system"), "role")

f = SimpleForm("role", i18n.translate("Node role"))
f.template = "admin/expertmode"

s = f:section(SimpleSection, nil, i18n.translate(
  "If this node has a special role within the freifunk network you can specify this role here. "
    .. "Please find out about the available roles and their impact first. "
    .. "Only change the role if you know what you are doing."))

o = s:option(ListValue, "role", i18n.translate("Role"))
o.default = role
o.rmempty = false
for _, role in ipairs(site.roles.list) do
  o:value(role, i18n.translate('gluon-luci-node-role:role:' .. role))
end

function f.handle(self, state, data)
  if state == FORM_VALID then
    uci:set(config, uci:get_first(config, "system"), "role", data.role)

    uci:save(config)
    uci:commit(config)
  end
end

return f
