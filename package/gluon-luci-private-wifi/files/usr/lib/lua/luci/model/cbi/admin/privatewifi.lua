local f, s, o, ssid
local uci = luci.model.uci.cursor()
local config = 'wireless'

-- where to read the configuration from
local primary_iface = 'wan_radio0'
local ssid = uci:get(config, primary_iface, "ssid")

f = SimpleForm("wifi", "Privates WLAN")
f.reset = false
f.template = "admin/expertmode"
f.submit = "Fertig"

s = f:section(SimpleSection, nil, [[
Dein Freifunk-Router kann ebenfalls die Reichweite deines privaten Netzes erweitern.
Hierfür wird der WAN-Port mit einem seperaten WLAN gebridged.
Diese Funktionalität ist völlig unabhängig von Freifunk.
Beachte, dass du nicht gleichzeitig das Meshen über den WAN Port aktiviert haben solltest.
]])

o = s:option(Flag, "enabled", "Aktiviert")
o.default = (ssid and not uci:get_bool(config, primary_iface, "disabled")) and o.enabled or o.disabled
o.rmempty = false

o = s:option(Value, "ssid", "Name (SSID)")
o.default = ssid

o = s:option(Value, "key", "Schlüssel", "8-63 Zeichen")
o.datatype = "wpakey"
o.default = uci:get(config, primary_iface, "key")

function f.handle(self, state, data)
  if state == FORM_VALID then
    uci:foreach(config, "wifi-device",
      function(s)
        local device = s['.name']
        local name   = "wan_" .. device

        if data.enabled == '1' then
          -- set up WAN wifi-iface
          local t      = uci:get_all(config, name) or {}

          t.device     = device
          t.network    = "wan"
          t.mode       = 'ap'
          t.encryption = 'psk2'
          t.ssid       = data.ssid
          t.key        = data.key
          t.disabled   = "false"

          uci:section(config, "wifi-iface", name, t)
        else
          -- disable WAN wifi-iface
          uci:set(config, name, "disabled", "true")
        end
    end)

    uci:save(config)
    uci:commit(config)
  end
end

return f
