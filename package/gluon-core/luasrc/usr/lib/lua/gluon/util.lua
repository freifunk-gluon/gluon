local bit = require 'bit'
local posix_glob = require 'posix.glob'
local hash = require 'hash'
local sysconfig = require 'gluon.sysconfig'
local site = require 'gluon.site'


local M = {}

-- Writes all lines from the file input to the file output except those starting with prefix
-- Doesn't close the output file, but returns the file object
local function do_filter_prefix(input, output, prefix)
	local f = io.open(output, 'w+')
	local l = prefix:len()

	for line in io.lines(input) do
		if line:sub(1, l) ~= prefix then
			f:write(line, '\n')
		end
	end

	return f
end

function M.trim(str)
	return str:gsub("^%s*(.-)%s*$", "%1")
end

function M.contains(table, value)
	for k, v in pairs(table) do
		if value == v then
			return k
		end
	end
	return false
end

function M.file_contains_line(path, value)
	for line in io.lines(path) do
		if line == value then
			return true
		end
	end
	return false
end

function M.add_to_set(t, itm)
	for _,v in ipairs(t) do
		if v == itm then return false end
	end
	table.insert(t, itm)
	return true
end

function M.remove_from_set(t, itm)
	local i = 1
	local changed = false
	while i <= #t do
		if t[i] == itm then
			table.remove(t, i)
			changed = true
		else
			i = i + 1
		end
	end
	return changed
end

-- Removes all lines starting with a prefix from a file, optionally adding a new one
function M.replace_prefix(file, prefix, add)
	local tmp = file .. '.tmp'
	local f = do_filter_prefix(file, tmp, prefix)
	if add then
		f:write(add)
	end
	f:close()
	os.rename(tmp, file)
end

local function readall(f)
	if not f then
		return nil
	end

	local data = f:read('*a')
	f:close()
	return data
end

function M.readfile(file)
	return readall(io.open(file))
end

function M.exec(command)
	return readall(io.popen(command))
end

function M.node_id()
	return string.gsub(sysconfig.primary_mac, ':', '')
end

function M.default_hostname()
	return site.hostname_prefix('') .. M.node_id()
end

function M.domain_seed_bytes(key, length)
	local ret = ''
	local v = ''
	local i = 0

	-- Inspired by HKDF key expansion, but much simpler, as we don't need
	-- cryptographic strength
	while ret:len() < 2*length do
		i = i + 1
		v = hash.md5(v .. key .. site.domain_seed():lower() .. i)
		ret = ret .. v
	end

	return ret:sub(0, 2*length)
end

function M.get_mesh_devices(uconn)
	local dump = uconn:call("network.interface", "dump", {})
	local devices = {}
	for _, interface in ipairs(dump.interface) do
	    if ( (interface.proto == "gluon_mesh") and interface.up ) then
			table.insert(devices, interface.device)
	    end
	end
	return devices
end

-- Safe glob: returns an empty table when the glob fails because of
-- a non-existing path
function M.glob(pattern)
	return posix_glob.glob(pattern) or {}
end

local function find_phy_by_path(path)
	local phy = M.glob('/sys/devices/' .. path .. '/ieee80211/phy*')[1]
		or M.glob('/sys/devices/platform/' .. path .. '/ieee80211/phy*')[1]

	if phy then
		return phy:match('([^/]+)$')
	end
end

local function find_phy_by_macaddr(macaddr)
	local addr = macaddr:lower()
	for _, file in ipairs(M.glob('/sys/class/ieee80211/*/macaddress')) do
		if M.trim(M.readfile(file)) == addr then
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

-- Generates a (hopefully) unique MAC address
-- The parameter defines the ID to add to the MAC address
--
-- IDs defined so far:
-- 0: client0; WAN
-- 1: mesh0
-- 2: (unused)
-- 3: wan_radio0 (private WLAN); batman-adv primary address
-- 4: client1; LAN
-- 5: mesh1
-- 6: (unused)
-- 7: wan_radio1 (private WLAN); mesh VPN
function M.generate_mac(i)
	if i > 7 or i < 0 then return nil end -- max allowed id (0b111)

	local hashed = string.sub(hash.md5(sysconfig.primary_mac), 0, 12)
	local m1, m2, m3, m4, m5, m6 = string.match(hashed, '(%x%x)(%x%x)(%x%x)(%x%x)(%x%x)(%x%x)')

	m1 = tonumber(m1, 16)
	m6 = tonumber(m6, 16)

	m1 = bit.bor(m1, 0x02)  -- set locally administered bit
	m1 = bit.band(m1, 0xFE) -- unset the multicast bit

	-- It's necessary that the first 45 bits of the MAC address don't
	-- vary on a single hardware interface, since some chips are using
	-- a hardware MAC filter. (e.g 'rt305x')

	m6 = bit.band(m6, 0xF8) -- zero the last three bits (space needed for counting)
	m6 = m6 + i                   -- add virtual interface id

	return string.format('%02x:%s:%s:%s:%s:%02x', m1, m2, m3, m4, m5, m6)
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

	return M.generate_mac(4*(index-1) + (vif-1))
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
		local hwmode = radio.hwmode

		if hwmode == '11g' or hwmode == '11ng' then
			f(radio, index, site.wifi24)
		elseif hwmode == '11a' or hwmode == '11na' then
			f(radio, index, site.wifi5)
		end
	end
end

function M.get_uptime()
	local uptime_file = M.readfile("/proc/uptime")
	if uptime_file == nil then
		-- Something went wrong reading "/proc/uptime"
		return nil
	end
	return tonumber(uptime_file:match('^[^ ]+'))
end

return M
