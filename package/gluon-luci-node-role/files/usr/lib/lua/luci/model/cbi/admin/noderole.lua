local f, s, o
local site = require 'gluon.site_config'
local uci = luci.model.uci.cursor()
local config = 'gluon-node-info'

-- where to read the configuration from
local role = uci:get(config, uci:get_first(config, "system"), "role")

f = SimpleForm("role", "Verwendungszweck")
f.reset = false
f.template = "admin/expertmode"
f.submit = "Fertig"

s = f:section(SimpleSection, nil, [[
Wenn dein Freifunk-Router eine besondere Rolle im Freifunk Netz einnimmt, kannst du diese hier angeben.
Bringe bitte zuvor in Erfahrung welche Auswirkungen die zur Verfügung stehenden Rollen im Freifunk-Netz haben.
Setze die Rolle nur, wenn du weißt was du machst.
]])

o = s:option(ListValue, "role", "Rolle")
o.default = role
o.rmempty = false
for role, prettyname in pairs(site.roles.list) do
  o:value(role, prettyname)
end

function f.handle(self, state, data)
  if state == FORM_VALID then
    uci:set(config, uci:get_first(config, "system"), "role", data.role)

    uci:save(config)
    uci:commit(config)
  end
end

return f
