local uci = require("simple-uci").cursor()
local wireless = require 'gluon.wireless'

-- where to read the configuration from
local primary_iface = 'ap_radio0'

local f = Form(translate("Private AP"))

local s = f:section(Section, nil, translate(
	'Your node can additionally offer a private client access point '
	.. 'which allows you to use the mesh like regular private wifi '
	.. 'with your own network, LAN addresses, password, etc.'
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

local subnet4 = s:option(Value, "subnet4", translate("Subnet IPv4 (NAT)"), translate("IPv4 CIDR"))
subnet4:depends(enabled, true)
subnet4.datatype = "maxlength(32)"
subnet4.default = uci:get('network', 'ap', 'ipaddr') or '192.168.178.1/24'

local subnet6 = s:option(Value, "subnet6", translate("ULA IPv6"), translate("IPv6 CIDR or 'auto'"))
subnet6:depends(enabled, true)
subnet6.datatype = "maxlength(128)"
subnet6.default = uci:get('network', 'globals', 'ula_prefix')

-- TODO: ipv4 when prefix4() set? or always? allow custom cidr
-- TODO: allow mesh (regular meshing) on private net?

function f:write()
	uci:set('network', 'globals', 'ula_prefix', subnet6.data)

	uci:section('network', 'interface', 'ap', {
		type = 'bridge',
		ifname = {},
		proto = 'static',
		ipaddr = subnet4.data,
		ip6assign = '64',
	})

	uci:section('dhcp', 'dhcp', 'ap', {
		interface = 'ap',
		start = '100',
		limit = '150',
		leasetime = '12h',
	})

	wireless.foreach_radio(uci, function(radio, index)
		local radio_name = radio['.name']
		local suffix = radio_name:match('^radio(%d+)$')
		local name   = "ap_" .. radio_name

		if enabled.data then
			local macaddr = wireless.get_wlan_mac(uci, radio, index, 5)

			uci:section('wireless', 'wifi-iface', name, {
				device     = radio_name,
				network    = 'ap',
				mode       = 'ap',
				encryption = encryption.data,
				ssid       = ssid.data,
				key        = key.data,
				macaddr    = macaddr,
				ifname     = suffix and 'ap' .. suffix,
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

	uci:commit('network')
	uci:commit('wireless')
end

return f
