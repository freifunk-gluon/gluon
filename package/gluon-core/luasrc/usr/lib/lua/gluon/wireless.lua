local sysconfig = require 'gluon.sysconfig'
local site = require 'gluon.site'
local util = require 'gluon.util'

local unistd = require 'posix.unistd'

local iwinfo = require 'iwinfo'

local M = {}

function M.find_phy(config)
	local phyname = iwinfo.nl80211.phyname(config['.name'])
	if not phyname then
		phyname = iwinfo.nl80211.phyname(config['.name']:gsub("radio", "phy"))
	end
	return phyname
end

local function get_addresses(radio)
	local phy = M.find_phy(radio)
	if not phy then
		return function() end
	end

	return io.lines('/sys/class/ieee80211/' .. phy .. '/addresses')
end

local function get_wlan_mac_from_driver(radio, vif)
	local primary = sysconfig.primary_mac:lower()

	local addresses = {}
	for address in get_addresses(radio) do
		if address:lower() ~= primary then
			table.insert(addresses, address)
		end
	end

	-- Make sure we have at least 4 addresses
	if #addresses < 4 then
		return nil
	end

	return addresses[vif]
end

function M.get_wlan_mac(_, radio, index, vif)
	local addr = get_wlan_mac_from_driver(radio, vif)
	if addr then
		return addr
	end

	return util.generate_mac(4*(index-1) + (vif-1))
end

-- Iterate over all radios defined in UCI calling
-- f(radio, index, site.wifiX) for each radio found while passing
--  site.wifi24 for 2.4 GHz devices and site.wifi5 for 5 GHz ones.
function M.foreach_radio(uci, f)
	local radios = {}

	uci:foreach('wireless', 'wifi-device', function(radio)
		table.insert(radios, radio)
	end)

	for index, radio in ipairs(radios) do
		local band = radio.band

		if band == '2g' then
			f(radio, index, site.wifi24)
		elseif band == '5g' then
			f(radio, index, site.wifi5)
		end
	end
end

function M.preserve_channels(uci)
	return uci:get_bool('gluon', 'wireless', 'preserve_channels')
end

function M.device_supports_wpa3()
	return unistd.access('/lib/gluon/features/wpa3')
end

function M.device_supports_mfp(uci)
	local supports_mfp = true

	if not M.device_supports_wpa3() then
		return false
	end

	uci:foreach('wireless', 'wifi-device', function(radio)
		local phy = M.find_phy(radio)
		local phypath = '/sys/kernel/debug/ieee80211/' .. phy .. '/'

		if not util.file_contains_line(phypath .. 'hwflags', 'MFP_CAPABLE') then
			supports_mfp = false
			return false
		end
	end)

	return supports_mfp
end

function M.device_uses_wlan(uci)
	local ret = false

	uci:foreach('wireless', 'wifi-device', function()
		ret = true
		return false
	end)

	return ret
end

function M.device_uses_11a(uci)
	local ret = false

	uci:foreach('wireless', 'wifi-device', function(radio)
		if radio.band == '5g' then
			ret = true
			return false
		end
	end)

	return ret
end

return M
