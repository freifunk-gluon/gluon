local f, s, o, ssid
local uci = luci.model.uci.cursor()
local config = 'wireless'

-- where to read the configuration from
local primary_iface = 'wan_radio0'
local ssid = uci:get(config, primary_iface, "ssid")

f = SimpleForm("wifi", translate("Private WLAN"))
f.template = "admin/expertmode"

s = f:section(SimpleSection, nil, translate(
                'Your node can additionally extend your private network by bridging the WAN interface '
                  .. 'with a seperate WLAN. This feature is completely independent of the mesh functionality. '
                  .. 'Please note that the private WLAN and meshing on the WAN interface should not be enabled '
                  .. 'at the same time.'
))

o = s:option(Flag, "enabled", translate("Enabled"))
o.default = (ssid and not uci:get_bool(config, primary_iface, "disabled")) and o.enabled or o.disabled
o.rmempty = false

o = s:option(Value, "ssid", translate("Name (SSID)"))
o.default = ssid

o = s:option(Value, "key", translate("Key"), translate("8-63 characters"))
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
