local uci = require("simple-uci").cursor()
local wireless = require 'gluon.wireless'
local util = require 'gluon.util'

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

local private_enabled = false

uci:foreach('gluon', 'wireless_band', function(band_config)
	if util.contains(band_config.role or {}, 'private') then
		private_enabled = true
	end
end)

local enabled = s:option(Flag, "enabled", translate("Enabled"))
enabled.default = private_enabled

local warning = s:element('model/warning', {
	content = translate(
		'Meshing on WAN interface is enabled. ' ..
		'This can lead to problems.'
	),
	hide = not mesh_on_wan,
}, 'warning')
warning:depends(enabled, true)

local ssid = s:option(Value, "ssid", translate("Name (SSID)"))
ssid:depends(enabled, true)
ssid.datatype = "maxlength(32)"
ssid.default = uci:get('gluon', 'wireless', 'private_ssid')

local key = s:option(Value, "key", translate("Key"), translate("8-63 characters"))
key:depends(enabled, true)
key.datatype = "wpakey"
key.default = uci:get('gluon', 'wireless', 'private_key')

local encryption = s:option(ListValue, "encryption", translate("Encryption"))
encryption:depends(enabled, true)
encryption:value("psk2", translate("WPA2"))
if wireless.device_supports_wpa3() then
	encryption:value("sae-mixed", translate("WPA2 / WPA3"))
	encryption:value("sae", translate("WPA3"))
end
encryption.default = uci:get('gluon', 'wireless', 'private_encryption') or "psk2"

local mfp = s:option(ListValue, "mfp", translate("Management Frame Protection"))
mfp:depends(enabled, true)
mfp:value("0", translate("Disabled"))
if wireless.device_supports_mfp(uci) then
	mfp:value("1", translate("Optional"))
	mfp:value("2", translate("Required"))
end
mfp.default = uci:get('gluon', 'wireless', 'private_mfp') or "0"

function f:write()
	if enabled.data then
		-- set new private wifi configuration
		uci:set('gluon', 'wireless', 'private_ssid', ssid.data)
		uci:set('gluon', 'wireless', 'private_key', key.data)
		uci:set('gluon', 'wireless', 'private_encryption', encryption.data)
		uci:set('gluon', 'wireless', 'private_mfp', mfp.data)
	end

	uci:foreach('gluon', 'wireless_band', function(band_config)
		local band = band_config['.name']
		local roles = uci:get_list('gluon', band, 'role')
		if enabled.data then
			util.add_to_set(roles, 'private')
		else
			util.remove_from_set(roles, 'private')
		end
		uci:set_list('gluon', band, 'role', roles)
	end)

	uci:commit('gluon')
	os.execute('exec gluon-reconfigure >/dev/null')
end

return f
