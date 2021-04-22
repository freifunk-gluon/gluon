local uci = require("simple-uci").cursor()
local platform = require 'gluon.platform'
local wireless = require 'gluon.wireless'
local util = require 'gluon.util'

-- where to read the configuration from
local primary_iface = 'wan_radio0'

local f = Form(translate("Private WLAN"))

if not util.in_setup_mode() then
	f.submit = translate('Save & apply')
end

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

local encryption = s:option(ListValue, "encryption", translate("Encryption"))
encryption:depends(enabled, true)
encryption:value("psk2", translate("WPA2"))
if platform.device_supports_wpa3() then
	encryption:value("psk3-mixed", translate("WPA2 / WPA3"))
	encryption:value("psk3", translate("WPA3"))
end
encryption.default = uci:get('wireless', primary_iface, 'encryption') or "psk2"

local mfp = s:option(ListValue, "mfp", translate("Management Frame Protection"))
mfp:depends(enabled, true)
mfp:value("0", translate("Disabled"))
if platform.device_supports_mfp(uci) then
	mfp:value("1", translate("Optional"))
	mfp:value("2", translate("Required"))
end
mfp.default = uci:get('wireless', primary_iface, 'ieee80211w') or "0"


function f:write()
	wireless.foreach_radio(uci, function(radio, index)
		local radio_name = radio['.name']
		local name   = "wan_" .. radio_name

		if enabled.data then
			local macaddr = wireless.get_wlan_mac(uci, radio, index, 4)

			uci:section('wireless', 'wifi-iface', name, {
				device     = radio_name,
				network    = 'wan',
				mode       = 'ap',
				encryption = encryption.data,
				ssid       = ssid.data,
				key        = key.data,
				macaddr    = macaddr,
				disabled   = false,
			})

			-- hostapd-mini won't start in case 802.11w is configured
			if platform.device_supports_mfp(uci) then
				uci:set('wireless', name, 'ieee80211w', mfp.data)
			else
				uci:delete('wireless', name, 'ieee80211w')
			end
		else
			uci:set('wireless', name, "disabled", true)
		end
	end)

	uci:commit('wireless')

	if not util.in_setup_mode() then
		util.reconfigure_asynchronously()
	end
end

return f
