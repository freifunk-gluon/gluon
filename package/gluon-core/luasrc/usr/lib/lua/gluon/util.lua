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
	return (str:gsub("^%s*(.-)%s*$", "%1"))
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
	return (string.gsub(sysconfig.primary_mac, ':', ''))
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
	return posix_glob.glob(pattern, 0) or {}
end

-- Generates a (hopefully) unique MAC address
-- The parameter defines the ID to add to the MAC address
--
-- IDs defined so far:
-- 0: client0; WAN
-- 1: mesh0
-- 2: owe0
-- 3: wan_radio0 (private WLAN); batman-adv primary address
-- 4: client1; LAN
-- 5: mesh1
-- 6: owe1
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

function M.get_uptime()
	local uptime_file = M.readfile("/proc/uptime")
	if uptime_file == nil then
		-- Something went wrong reading "/proc/uptime"
		return nil
	end
	return tonumber(uptime_file:match('^[^ ]+'))
end

return M
