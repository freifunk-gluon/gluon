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


local io = io
local os = os
local string = string
local tonumber = tonumber
local ipairs = ipairs
local table = table

local nixio = require 'nixio'
local hash = require 'hash'
local sysconfig = require 'gluon.sysconfig'
local site = require 'gluon.site_config'
local uci = require('luci.model.uci').cursor()
local lutil = require 'luci.util'
local fs = require 'nixio.fs'


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


local function find_phy_by_path(path)
  for phy in fs.glob('/sys/devices/' .. path .. '/ieee80211/phy*') do
    return phy:match('([^/]+)$')
  end
end

local function find_phy_by_macaddr(macaddr)
  local addr = macaddr:lower()
  for file in fs.glob('/sys/class/ieee80211/*/macaddress') do
    if lutil.trim(fs.readfile(file)) == addr then
      return file:match('([^/]+)/macaddress$')
    end
  end
end

local function find_phy(radio)
  local config = uci:get_all('wireless', radio)

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
  local phy = find_phy(radio)
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
-- 2: ibss0
-- 3: wan_radio0 (private WLAN); batman-adv primary address
-- 4: client1; LAN
-- 5: mesh1
-- 6: ibss1
-- 7: wan_radio1 (private WLAN); mesh VPN
function generate_mac(i)
  if i > 7 or i < 0 then return nil end -- max allowed id (0b111)

  local hashed = string.sub(hash.md5(sysconfig.primary_mac), 0, 12)
  local m1, m2, m3, m4, m5, m6 = string.match(hashed, '(%x%x)(%x%x)(%x%x)(%x%x)(%x%x)(%x%x)')

  m1 = tonumber(m1, 16)
  m6 = tonumber(m6, 16)

  m1 = nixio.bit.bor(m1, 0x02)  -- set locally administered bit
  m1 = nixio.bit.band(m1, 0xFE) -- unset the multicast bit

  -- It's necessary that the first 45 bits of the MAC address don't
  -- vary on a single hardware interface, since some chips are using
  -- a hardware MAC filter. (e.g 'rt305x')

  m6 = nixio.bit.band(m6, 0xF8) -- zero the last three bits (space needed for counting)
  m6 = m6 + i                   -- add virtual interface id

  return string.format('%02x:%s:%s:%s:%s:%02x', m1, m2, m3, m4, m5, m6)
end

local function get_wlan_mac_from_driver(radio, vif)
  local primary = sysconfig.primary_mac:lower()

  local i = 1
  for addr in get_addresses(radio) do
    if addr:lower() ~= primary then
      if i == vif then
        return addr
      end

      i = i + 1
    end
  end
end

function get_wlan_mac(radio, index, vif)
  local addr = get_wlan_mac_from_driver(radio, vif)
  if addr then
    return addr
  end

  return generate_mac(4*(index-1) + (vif-1))
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
