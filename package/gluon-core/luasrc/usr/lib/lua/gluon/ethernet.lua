local util = require 'gluon.util'
local unistd = require 'posix.unistd'
local dirent = require 'posix.dirent'
local uci = require('simple-uci').cursor()

local M = {}

local function has_devtype(iface_dir, devtype)
	return util.file_contains_line(iface_dir..'/uevent', 'DEVTYPE='..devtype)
end

local function is_physical(iface_dir)
	return unistd.access(iface_dir .. '/device') == 0
end

local function is_swconfig()
	local has = false

	uci:foreach("network", "switch", function()
		has = true
	end)

	uci:foreach("network", "switch_vlan", function()
		has = true
	end)

	return has
end

local function interfaces_raw()
	local eth_ifaces = {}
	local ifaces_dir = '/sys/class/net/'

	for iface in dirent.files(ifaces_dir) do
		if iface ~= '.' and iface ~= '..' then
			local iface_dir = ifaces_dir .. iface
			if is_physical(iface_dir) and not has_devtype(iface_dir, 'wlan') then
				table.insert(eth_ifaces, iface)
			end
		end
	end

	return eth_ifaces
end

-- In comparison to interfaces_raw, this skips non-DSA ports on DSA devices,
-- as for ex. hap ac² has a special eth0 that shouldn't be touched
function M.interfaces()
	local intfs = interfaces_raw()

	if M.get_switch_type() == 'dsa' then
		local new_intfs = {}
		for _, intf in ipairs(intfs) do
			if has_devtype('/sys/class/net/' .. intf, 'dsa') then
				table.insert(new_intfs, intf)
			end
		end

		return new_intfs
	end

	return intfs
end

function M.is_vlan(intf)
	return has_devtype('/sys/class/net/' .. intf, 'vlan')
end

function M.get_switch_type()
	if is_swconfig() then
		return 'swconfig'
	end

	for _, intf in ipairs(interfaces_raw()) do
		if has_devtype('/sys/class/net/' .. intf, 'dsa') then
			return 'dsa'
		end
	end

	return 'none'
end

return M
