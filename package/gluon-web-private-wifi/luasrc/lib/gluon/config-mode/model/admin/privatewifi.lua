local uci = require("simple-uci").cursor()
local wireless = require 'gluon.wireless'
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

local uplink_interfaces = util.get_role_interfaces(uci, 'uplink')
local mesh_on_wan = false

for _, iface in ipairs(util.get_role_interfaces(uci, 'mesh')) do
	if util.contains(uplink_interfaces, iface) then
		mesh_on_wan = true
	end
end

local enabled = s:option(Flag, "enabled", translate("Enabled"))
enabled.default = uci:get('wireless', primary_iface) and not uci:get_bool('wireless', primary_iface, "disabled")

local warning = s:element('model/warning', {
	content = mesh_on_wan and translate(
		'Meshing on WAN interface is enabled.' ..
		'This can lead to problems.'
	) or nil,
}, 'warning')
warning:depends(enabled, true)

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
if wireless.device_supports_wpa3() then
	encryption:value("psk3-mixed", translate("WPA2 / WPA3"))
	encryption:value("psk3", translate("WPA3"))
end
encryption.default = uci:get('wireless', primary_iface, 'encryption') or "psk2"

local mfp = s:option(ListValue, "mfp", translate("Management Frame Protection"))
mfp:depends(enabled, true)
mfp:value("0", translate("Disabled"))
if wireless.device_supports_mfp(uci) then
	mfp:value("1", translate("Optional"))
	mfp:value("2", translate("Required"))
end
mfp.default = uci:get('wireless', primary_iface, 'ieee80211w') or "0"


function f:write()
	wireless.foreach_radio(uci, function(radio, index)
		local radio_name = radio['.name']
		local suffix = radio_name:match('^radio(%d+)$')
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
				ifname     = suffix and 'wan' .. suffix,
				disabled   = false,
			})

			-- hostapd-mini won't start in case 802.11w is configured
			if wireless.device_supports_mfp(uci) then
				uci:set('wireless', name, 'ieee80211w', mfp.data)
			else
				uci:delete('wireless', name, 'ieee80211w')
			end
		else
			uci:set('wireless', name, "disabled", true)
		end
	end)

	uci:commit('wireless')
end

return f
