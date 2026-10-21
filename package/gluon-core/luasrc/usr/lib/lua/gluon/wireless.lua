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
--  site.wifi24 for 2.4 GHz devices, site.wifi5 for 5 GHz ones
--  and site.wifi6 for 6 GHz devices
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
		elseif band == '6g' then
			f(radio, index-1, site.wifi6)
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

function M.radio_roles(uci, radio)
	return uci:get_list('gluon', 'band_' .. radio.band, 'role')
end

function M.is_outdoor(uci)
	return uci:get_bool('gluon', 'wireless', 'outdoor')
end

-- Channel widths in MHz that can be configured for a band or radio
M.channel_widths = {20, 40, 80, 160}

-- Per-radio settings are stored in wireless_radio sections of the gluon
-- config. Radios are identified by their path, as radio names may change.
-- Radios of a PHY supporting multiple radios share the path and are told
-- apart by their radio index.
local function radio_section(uci, radio)
	if not radio.path then
		return nil
	end

	local name
	uci:foreach('gluon', 'wireless_radio', function(section)
		if section.path == radio.path and section.radio == radio.radio then
			name = section['.name']
			return false
		end
	end)

	return name
end

-- Creates the settings section of a radio, returns nil for radios without
-- a path
function M.add_radio_section(uci, radio, values)
	if not radio.path then
		return nil
	end

	local section = uci:section('gluon', 'wireless_radio', nil, values)
	uci:set('gluon', section, 'path', radio.path)
	uci:set('gluon', section, 'radio', radio.radio)
	return section
end

function M.has_radio_section(uci, radio)
	return radio_section(uci, radio) ~= nil
end

function M.radio_option(uci, radio, option)
	local section = radio_section(uci, radio)
	if not section then
		return nil
	end

	-- Only return the value, not the error of a missing option
	local value = uci:get('gluon', section, option)
	return value
end

-- Setting an option to nil removes it
function M.set_radio_option(uci, radio, option, value)
	local section = radio_section(uci, radio)
	if not section then
		if value == nil then
			return
		end

		section = M.add_radio_section(uci, radio)
		if not section then
			return
		end
	end

	uci:set('gluon', section, option, value)
end

return M
