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


local function escape_args(ret, arg0, ...)
	if not arg0 then
		return ret
	end

	return escape_args(ret .. "'" .. string.gsub(arg0, "'", "'\\''") .. "' ", ...)
end


local os = os
local string = string
local tonumber = tonumber
local ipairs = ipairs
local table = table

local nixio = require 'nixio'
local hash = require 'hash'
local sysconfig = require 'gluon.sysconfig'
local platform = require 'gluon.platform'
local site = require 'gluon.site_config'
local uci = require('luci.model.uci').cursor()


module 'gluon.util'

function exec(...)
	return os.execute(escape_args('', 'exec', ...))
end

-- Removes all lines starting with a prefix from a file, optionally adding a new one
function replace_prefix(file, prefix, add)
	local tmp = file .. '.tmp'
	local f = do_filter_prefix(file, tmp, prefix)
	if add then
		f:write(add)
	end
	f:close()
	os.rename(tmp, file)
end

function readline(fd)
	local line = fd:read('*l')
	fd:close()
	return line
end

function lock(file)
	exec('lock', file)
end

function unlock(file)
	exec('lock', '-u', file)
end

function node_id()
  return string.gsub(sysconfig.primary_mac, ':', '')
end

-- Generates a (hopefully) unique MAC address
-- The first parameter defines the function and the second
-- parameter an ID to add to the MAC address
-- Functions and IDs defined so far:
-- (1, 0): WAN (for mesh-on-WAN)
-- (1, 1): LAN (for mesh-on-LAN)
-- (2, n): client interface for the n'th radio
-- (3, n): adhoc interface for n'th radio
-- (4, 0): mesh VPN
-- (5, n): mesh interface for n'th radio (802.11s)
function generate_mac(f, i)
  local hashed = string.sub(hash.md5(sysconfig.primary_mac), 0, 12)
  local m1, m2, m3, m4, m5, m6 = string.match(hashed, '(%x%x)(%x%x)(%x%x)(%x%x)(%x%x)(%x%x)')

  m1 = tonumber(m1, 16)
  m3 = tonumber(m3, 16)
  m6 = tonumber(m6, 16)

  m1 = nixio.bit.bor(m1, 0x02)  -- set locally administered bit
  m1 = nixio.bit.band(m1, 0xFE) -- unset the multicast bit
  m3 = (m3+i) % 0x100           -- add interface identifier

  -- It's necessary that the last bits of the mac do
  -- not vary on a single interface, since some chips are using
  -- a hardware mac filter. (e.g 'ramips-rt305x')

  m6 = nixio.bit.band(m6, 0xF8) -- zero the last three bits (space needed for counting)
  m6 = (m6+f) % 0x100           -- add virtual interface id

  return string.format('%02x:%s:%02x:%s:%s:%02x', m1, m2, m3, m4, m5, m6)
end

-- Iterate over all radios defined in UCI calling
-- f(radio, index, site.wifiX) for each radio found while passing
--  site.wifi24 for 2.4 GHz devices and site.wifi5 for 5 GHz ones.
function iterate_radios(f)
  local radios = {}

  uci:foreach('wireless', 'wifi-device',
    function(s)
      table.insert(radios, s['.name'])
    end
  )

  for index, radio in ipairs(radios) do
    local hwmode = uci:get('wireless', radio, 'hwmode')

    if hwmode == '11g' or hwmode == '11ng' then
      f(radio, index, site.wifi24)
    elseif hwmode == '11a' or hwmode == '11na' then
      f(radio, index, site.wifi5)
    end
  end
end
