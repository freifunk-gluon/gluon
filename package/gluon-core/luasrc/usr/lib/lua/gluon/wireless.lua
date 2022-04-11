local sysconfig = require 'gluon.sysconfig'
local site = require 'gluon.site'
local util = require 'gluon.util'

local unistd = require 'posix.unistd'
local dirent = require 'posix.dirent'


local M = {}

local function find_phy_by_path(path)
	local device_path, phy_offset = string.match(path, "^(.+)%+(%d+)$")

	-- Special handling required for multi-phy devices
	if device_path == nil then
		device_path = path
		phy_offset = '0'
	end

	-- Find the device path. Either it's located at /sys/devices or /sys/devices/platform
	local path_prefix = ''
	if not unistd.access('/sys/devices/' .. device_path .. '/ieee80211') then
		path_prefix = 'platform/'
	end

	-- Get all available PHYs of the device and dertermine the one with the lowest index
	local phy_names = dirent.dir('/sys/devices/' .. path_prefix .. device_path .. '/ieee80211')
	local device_phy_idxs = {}
	for _, v in ipairs(phy_names) do
		local phy_idx = v:match('^phy(%d+)$')

		if phy_idx ~= nil then
			table.insert(device_phy_idxs, tonumber(phy_idx))
		end
	end

	table.sort(device_phy_idxs)

	-- Index starts at 1
	return 'phy' .. device_phy_idxs[tonumber(phy_offset) + 1]
end

local function find_phy_by_macaddr(macaddr)
	local addr = macaddr:lower()
	for _, file in ipairs(util.glob('/sys/class/ieee80211/*/macaddress')) do
		if util.trim(util.readfile(file)) == addr then
			return file:match('([^/]+)/macaddress$')
		end
	end
end

function M.find_phy(config)
	if not config or config.type ~= 'mac80211' then
		return nil
	elseif config.path then
		return find_phy_by_path(config.path)
	elseif config.macaddr then
		return find_phy_by_macaddr(config.macaddr)
	else
		return nil
	end
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

	for i, addr in ipairs(addresses) do
		if i == vif then
			return addr
		end
	end
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
		elseif band == '60g' then
			f(radio, index, site.wifi60)
		end
	end
end

function M.preserve_channels(uci)
	return uci:get('gluon', 'wireless', 'preserve_channels')
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

function M.device_uses_ad(uci)
	local ret = false

	uci:foreach('wireless', 'wifi-device', function(radio)
		if radio.band == '60g' then
			ret = true
			return false
		end
	end)

	return ret
end

return M
