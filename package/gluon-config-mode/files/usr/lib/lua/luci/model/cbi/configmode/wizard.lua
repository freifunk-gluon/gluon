local configmode = require "luci.tools.configmode"
local meshvpn_name = "mesh_vpn"
local uci = luci.model.uci.cursor()
local f, s, o

-- prepare fastd key as early as possible
configmode.setup_fastd_secret(meshvpn_name)

f = SimpleForm("wizard", "Wizard", "Lorem ipsum...")

s = f:section(SimpleSection, "Grundeinstellungen", nil)

o = s:option(Value, "_hostname", "Knotenname")
o.value = uci:get_first("system", "system", "hostname")
o.rmempty = false
o.datatype = "hostname"

o = s:option(Flag, "_meshvpn", "Mesh-VPN aktivieren?")
o.default = string.format("%d", uci:get("fastd", meshvpn_name, "enabled", "0"))
o.rmempty = false

o = s:option(Flag, "_bwlimit", "Bandbreitenbegrenzung aktivieren?")
o.default = string.format("%d", uci:get_first("freifunk", "bandwidth", "enabled", "0"))
o.rmempty = false

o = s:option(Flag, "_autoupdate", "Automatische Updates aktivieren?")
o.default = string.format("%d", uci:get_first("autoupdater", "autoupdater", "enabled", "0"))
o.rmempty = false

s = f:section(SimpleSection, "GPS Koordinaten", "Hier kannst du die GPS Koordinaten deines Knotens festlegen damit er in der Karte angezeigt werden kann.")

o = s:option(Value, "_latitude", "Breitengrad")
o.default = string.format("%f", uci:get_first("system", "location", "latitude", "0"))
o.rmempty = false
o.datatype = "float"

o = s:option(Value, "_longitude", "Längengrad")
o.default = string.format("%f", uci:get_first("system", "location", "longitude", "0"))
o.rmempty = false
o.datatype = "float"

function f.handle(self, state, data)
  if state == FORM_VALID then
    local stat = false

    uci:foreach("autoupdater", "autoupdater", function(s)
            uci:set("autoupdater", s[".name"], "enabled", data._autoupdate)
            end)
    uci:save("autoupdater")
    uci:commit("autoupdater")

    uci:foreach("freifunk", "bandwidth", function(s)
            uci:set("freifunk", s[".name"], "enabled", data._bwlimit)
            end)
    uci:save("freifunk")
    uci:commit("freifunk")

    uci:set("fastd", meshvpn_name, "enabled", data._meshvpn)
    uci:save("fastd")
    uci:commit("fastd")

    uci:foreach("system", "system", function(s)
            uci:set("system", s[".name"], "hostname", data._hostname)
            end)

    uci:foreach("system", "location", function(s)
            uci:set("system", s[".name"], "latitude", data._latitude)
            uci:set("system", s[".name"], "longitude", data._longitude)
            end)
    uci:save("system")
    uci:commit("system")

    luci.http.redirect(luci.dispatcher.build_url("configmode", "reboot"))
  end

  return true
end

return f
