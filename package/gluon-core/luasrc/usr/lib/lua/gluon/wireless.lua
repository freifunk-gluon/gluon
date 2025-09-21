local sysconfig = require 'gluon.sysconfig'
local site = require 'gluon.site'
local util = require 'gluon.util'

local unistd = require 'posix.unistd'

local iwinfo = require 'iwinfo'

local M = {}

function M.find_phy(config)
	return iwinfo.nl80211.phyname(config['.name'])
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

	return addresses[vif+1]
end

function M.supports_channel(radio, channel)
	local phy = M.find_phy(radio)
	for _, chan in ipairs(iwinfo.nl80211.freqlist(phy)) do
		if channel == chan.channel then
			return true
		end
	end
	return false
end

local radio_mac_offsets = {
	client = 0,
	mesh = 1,
	owe = 2,
	wan_radio = 3,
}

function M.get_wlan_mac(func, index, radio)
	local offset = radio_mac_offsets[func]
	if offset == nil then
		return nil
	end
	if radio then
		local addr = get_wlan_mac_from_driver(radio, offset)
		if addr then
			return addr
		end
	end

	return util.generate_mac(4*index + offset)
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

		-- radio index is zero-based
		if band == '2g' then
			f(radio, index-1, site.wifi24)
		elseif band == '5g' then
			f(radio, index-1, site.wifi5)
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

function M.device_uses_band(uci, band)
	local ret = false

	uci:foreach('wireless', 'wifi-device', function(radio)
		if radio.band == band then
			ret = true
			return false
		end
	end)

	return ret
end

return M
