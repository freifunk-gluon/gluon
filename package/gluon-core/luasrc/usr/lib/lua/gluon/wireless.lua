local sysconfig = require 'gluon.sysconfig'
local site = require 'gluon.site'
local util = require 'gluon.util'


local M = {}

local function find_phy_by_path(path)
	local phy = util.glob('/sys/devices/' .. path .. '/ieee80211/phy*')[1]
		or util.glob('/sys/devices/platform/' .. path .. '/ieee80211/phy*')[1]

	if phy then
		return phy:match('([^/]+)$')
	end
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
		end
	end
end

function M.preserve_channels(uci)
	return uci:get_first('gluon-core', 'wireless', 'preserve_channels')
end

return M
