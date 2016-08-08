local uci = luci.model.uci.cursor()
local util = require 'gluon.util'

local f, s, o, ssid
local config = 'wireless'

-- where to read the configuration from
local primary_iface = 'wan_radio0'
local ssid = uci:get(config, primary_iface, "ssid")

f = SimpleForm("wifi", translate("Private WLAN"))
f.template = "admin/expertmode"

s = f:section(SimpleSection, nil, translate(
                'Your node can additionally extend your private network by bridging the WAN interface '
                  .. 'with a separate WLAN. This feature is completely independent of the mesh functionality. '
                  .. 'Please note that the private WLAN and meshing on the WAN interface should not be enabled '
                  .. 'at the same time.'
))

o = s:option(Flag, "enabled", translate("Enabled"))
o.default = (ssid and not uci:get_bool(config, primary_iface, "disabled")) and o.enabled or o.disabled
o.rmempty = false

o = s:option(Value, "ssid", translate("Name (SSID)"))
o:depends("enabled", '1')
o.datatype = "maxlength(32)"
o.default = ssid

o = s:option(Value, "key", translate("Key"), translate("8-63 characters"))
o:depends("enabled", '1')
o.datatype = "wpakey"
o.default = uci:get(config, primary_iface, "key")

function f.handle(self, state, data)
  if state == FORM_VALID then
    uci:foreach(config, "wifi-device",
      function(s)
        local radio = s['.name']
        local name   = "wan_" .. radio

        if data.enabled == '1' then
          -- get_wlan_mac_from_driver will return nil (and thus leave the
          -- MAC address unset) if the driver doesn't provide enough addresses
          local macaddr = util.get_wlan_mac_from_driver(radio, 4)

          -- set up WAN wifi-iface
          uci:section(config, "wifi-iface", name,
                      {
                        device     = radio,
                        network    = "wan",
                        mode       = 'ap',
                        encryption = 'psk2',
                        ssid       = data.ssid,
                        key        = data.key,
                        macaddr    = macaddr,
                        disabled   = 0,
                      }
          )
        else
          -- disable WAN wifi-iface
          uci:set(config, name, "disabled", 1)
        end
    end)

    uci:save(config)
    uci:commit(config)
  end
end

return f
