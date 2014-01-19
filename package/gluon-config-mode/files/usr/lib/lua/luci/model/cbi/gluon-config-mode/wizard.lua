local configmode = require "luci.tools.gluon-config-mode"
local meshvpn_name = "mesh_vpn"
local uci = luci.model.uci.cursor()
local f, s, o

-- prepare fastd key as early as possible
configmode.setup_fastd_secret(meshvpn_name)

f = SimpleForm("wizard", "Willkommen!", "Willkommen zum Einrichtungsassistenten für deinen neuen Lübecker Freifunk-Knoten.  Fülle das folgende Formular deinen Vorstellungen entsprechend aus und klicke anschließend auf den „Senden“-Button.")

s = f:section(SimpleSection, "Grundeinstellungen", nil)

o = s:option(Value, "_hostname", "Knotenname")
o.value = uci:get_first("system", "system", "hostname")
o.rmempty = false
o.datatype = "hostname"
o.description = "Öffentlicher Name deines Knotens. Wird z.B. für die Anzeige auf der Knotenkarte benutzt."

o = s:option(Flag, "_autoupdate", "Automatische Updates aktivieren?")
o.default = uci:get_bool("autoupdater", "settings", "enabled") and o.enabled or o.disabled
o.rmempty = false
o.description = "Aktiviert automatische Updates der Firmware (empfohlen)"

s = f:section(SimpleSection, "Mesh-VPN", "Nutzt die Internet-Verbindung, um diesem Knoten auch dann Zugang zum Freifunknetz zu geben, wenn er außerhalb der Funkreichweite anderer Freifunk-Knoten ist.")

o = s:option(Flag, "_meshvpn", "Mesh-VPN aktivieren?")
o.default = uci:get_bool("fastd", meshvpn_name, "enabled") and o.enabled or o.disabled
o.rmempty = false

o = s:option(Flag, "_limit_enabled", "Bandbreitenbegrenzung aktivieren?")
o.default = uci:get_bool("gluon-simple-tc", meshvpn_name, "enabled") and o.enabled or o.disabled
o.rmempty = false
o.description = "Begrenzt die Geschwindigkeit, mit der dieser Knoten auf das Internet zugreifen darf. Kann aktiviert werden, wenn der eigene Internetanschluss durch den Freifunkknoten merklich ausgebremst wird."

o = s:option(Value, "_limit_ingress", "Downstream")
o.value = uci:get("gluon-simple-tc", meshvpn_name, "limit_ingress")
o.rmempty = false
o.datatype = "integer"

o = s:option(Value, "_limit_egress", "Upstream")
o.value = uci:get("gluon-simple-tc", meshvpn_name, "limit_egress")
o.rmempty = false
o.datatype = "integer"

s = f:section(SimpleSection, "GPS Koordinaten", "Hier kannst du die GPS-Koordinaten deines Knotens eintragen, um ihn in der Knotenkarte anzeigen zu lassen.")

o = s:option(Flag, "_location", "Koordinaten veröffentlichen?")
o.default = uci:get_first("gluon-locaton", "location", "share_location", o.disabled)
o.rmempty = false

o = s:option(Value, "_latitude", "Breitengrad")
o.default = string.format("%f", uci:get_first("gluon-location", "location", "latitude", "0"))
o.rmempty = false
o.datatype = "float"

o = s:option(Value, "_longitude", "Längengrad")
o.default = string.format("%f", uci:get_first("gluon-location", "location", "longitude", "0"))
o.rmempty = false
o.datatype = "float"

function f.handle(self, state, data)
  if state == FORM_VALID then
    local stat = false

    uci:set("autoupdater", "settings", "enabled", data._autoupdate)
    uci:save("autoupdater")
    uci:commit("autoupdater")

    uci:set("gluon-simple-tc", meshvpn_name, "interface")
    uci:set("gluon-simple-tc", meshvpn_name, "enabled", data._limit_enabled)
    uci:set("gluon-simple-tc", meshvpn_name, "ifname", "mesh-vpn")
    uci:set("gluon-simple-tc", meshvpn_name, "limit_ingress", data._limit_ingress)
    uci:set("gluon-simple-tc", meshvpn_name, "limit_egress", data._limit_egress)
    uci:commit("gluon-simple-tc")

    uci:set("fastd", meshvpn_name, "enabled", data._meshvpn)
    uci:save("fastd")
    uci:commit("fastd")

    uci:foreach("system", "system", function(s)
            uci:set("system", s[".name"], "hostname", data._hostname)
            end)
    uci:save("system")
    uci:commit("system")

    uci:foreach("gluon-location", "location", function(s)
            uci:set("gluon-location", s[".name"], "share_location", data._location)
            uci:set("gluon-location", s[".name"], "latitude", data._latitude)
            uci:set("gluon-location", s[".name"], "longitude", data._longitude)
            end)
    uci:save("gluon-location")
    uci:commit("gluon-location")

    luci.http.redirect(luci.dispatcher.build_url("gluon-config-mode", "reboot"))
  end

  return true
end

return f
