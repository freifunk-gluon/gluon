local uci = require("simple-uci").cursor()
local util = require 'gluon.util'

-- where to read the configuration from
local primary_iface = 'wan_radio0'

local f = Form(translate("Private WLAN"))

local s = f:section(Section, nil, translate(
	'Your node can additionally extend your private network by bridging the WAN interface '
	.. 'with a separate WLAN. This feature is completely independent of the mesh functionality. '
	.. 'Please note that the private WLAN and meshing on the WAN interface should not be enabled '
	.. 'at the same time.'
))

local enabled = s:option(Flag, "enabled", translate("Enabled"))
enabled.default = uci:get('wireless', primary_iface) and not uci:get_bool('wireless', primary_iface, "disabled")

local ssid = s:option(Value, "ssid", translate("Name (SSID)"))
ssid:depends(enabled, true)
ssid.datatype = "maxlength(32)"
ssid.default = uci:get('wireless', primary_iface, "ssid")

local key = s:option(Value, "key", translate("Key"), translate("8-63 characters"))
key:depends(enabled, true)
key.datatype = "wpakey"
key.default = uci:get('wireless', primary_iface, "key")

function f:write()
	util.iterate_radios(uci, function(radio, index)
		local name   = "wan_" .. radio

		if enabled.data then
			local macaddr = util.get_wlan_mac(uci, radio, index, 4)

			uci:section('wireless', "wifi-iface", name, {
				device     = radio,
				network    = "wan",
				mode       = 'ap',
				encryption = 'psk2',
				ssid       = ssid.data,
				key        = key.data,
				macaddr    = macaddr,
				disabled   = false,
			})
		else
			uci:set('wireless', name, "disabled", true)
		end
	end)

	uci:commit('wireless')
end

return f
