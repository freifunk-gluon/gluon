#!/usr/bin/lua

local uci = require("simple-uci").cursor()
local util = require 'gluon.util'

local function safety_exit(t)
  io.write(t .. ", exiting with error code 2")
  os.exit(2)
end

local function logger(m)
  os.execute('logger -s -t "gluon-offline-ssid" -p 5 "' .. m .. '"')
end

local function file_exists(name)
   local f = io.open(name, "r")
   return f ~= nil and io.close(f)
end

local ut = util.get_uptime()
if ut < 60 then
  safety_exit('less than one minute')
end

-- only once every timeframe minutes the ssid will change to the offline-ssid
-- (set to 1 minute if you want to change immediately every time the router gets offline)
local minutes = tonumber(uci:get('gluon-offline-ssid', 'settings', 'switch_timeframe') or '30')

-- the first few minutes directly after reboot within which an offline-ssid always may be activated
-- (must be <= switch_timeframe)
local first = tonumber(uci:get('gluon-offline-ssid', 'settings', 'first') or '5')

-- the offline-ssid will start with this prefix use something short to leave space for the nodename
-- (no '~' allowed!)
local prefix = uci:get('gluon-offline-ssid', 'settings', 'prefix') or 'Offline_'

local disabled = uci:get('gluon-offline-ssid', 'settings', 'disabled') == '1' or false
if disabled then
  print("offline-ssid is disabled")
end
local phys = { length = 0 }
uci:foreach('wireless', 'wifi-device', function(config)
  local phy = util.find_phy(config)
  if phy then
    phys[config['.name']] = phy
    phys['length'] = phys['length'] + 1
  end
end)
if phys['length'] == 0 then
  safety_exit('no hostapd-phys')
end

local ssids = { }
uci:foreach('wireless', 'wifi-iface', function(config)
  if config['mode'] == 'ap' and config['network'] == 'client' then
    local ssid = config['ssid']
    if ssid then
      table.insert(ssids, { ssid = ssid , phy = phys[config['device']] })
    end
  end
end)
if #ssids == 0 then
  safety_exit('no ssids')
end

-- generate the ssid with either 'nodename', 'mac' or to use only the prefix set to 'none'
local settings_suffix = uci:get('gluon-offline-ssid', 'settings', 'suffix') or 'nodename'

local suffix
if settings_suffix == 'nodename' then
  local pretty_hostname = require 'pretty_hostname'
  suffix = pretty_hostname.get(uci)
  -- 32 would be possible as well
  if ( string.len(suffix) > 30 - string.len(prefix) ) then
    -- calculate the length of the first part of the node identifier in the offline-ssid
    local half = math.floor((28 - string.len(prefix) ) / 2)
    -- jump to this charakter for the last part of the name
    local skip = string.len(suffix) - half
    -- use the first and last part of the nodename for nodes with long name
    suffix = string.sub(suffix,0,half) .. '...' .. string.sub(suffix, skip)
  end
elseif settings_suffix == 'mac' then
  local sysconfig = require 'gluon.sysconfig'
  suffix = sysconfig.primary_mac
else
  -- 'none'
  suffix = ''
end
local offline_ssid = prefix .. suffix

-- temp file to count the offline incidents during switch_timeframe
local tmp = '/tmp/offline-ssid-count'
local off_count = '0'
if not file_exists(tmp) then
  assert(io.open(tmp, 'w')):write('0')
else
  off_count = tonumber(util.readfile(tmp))
end

-- if tq_limit_enabled is true, the offline ssid will only be set if there is no gateway reacheable
-- upper and lower limit to turn the offline_ssid on and off
-- in-between these two values the ssid will never be changed to preven it from toggeling every minute.
local tq_limit_enabled = tonumber(uci:get('gluon-offline-ssid', 'settings', 'tq_limit_enabled') or '0')

local check
local msg
if ( tq_limit_enabled == 1 ) then
  --  upper limit, above that the online ssid will be used
  local tq_limit_max = tonumber(uci:get('gluon-offline-ssid', 'settings', 'tq_limit_max') or '45')
  --  lower limit, below that the offline ssid will be used
  local tq_limit_min = tonumber(uci:get('gluon-offline-ssid', 'settings', 'tq_limit_min') or '35')
  -- grep the connection quality of the currently used gateway
  local gateway_tq = util.exec('batctl gwl | grep -e "^=>" -e "^\\*" | awk -F \'[()]\' \'{print $2}\' | tr -d " "')
  if ( gateway_tq == '' ) then
    -- there is no gateway
    gateway_tq = 0
  end
  msg = "tq is " .. gateway_tq

  if ( gateway_tq >= tq_limit_max ) then
    check = 1
  elseif ( gateway_tq < tq_limit_min ) then
    check = 0
  else
    -- get a clean run if we are in-between the grace period
    print(msg .. ", do nothing")
    os.exit(0)
  end
else
  msg = ""
  check = os.execute('batctl gwl -H | grep -v "gateways in range"')
end

local up = ut / 60
local m = math.floor(up % minutes)

-- debug:
print("uptime in minutes:"..up..", every "..minutes.." minutes, countdown:"..m)

local hup_needed = 0
local ssid_grep = 'grep "^ssid='

-- debug:
-- check=0 -- set this to set the node always offline

if check > 0 or disabled then
  print("node is online")
  -- check status for all physical devices
  for _, ssid in ipairs(ssids) do
    local hostapd = '/var/run/hostapd-' .. ssid.phy .. '.conf'

    -- first grep for online-SSID in hostapd file
    if os.execute(ssid_grep .. ssid.ssid .. '" ' .. hostapd) == 0 then
      print("current ssid is correct")
      break
    else
      -- set online
      -- debug: grep for offline_ssid in hostapd file
      if os.execute(ssid_grep .. offline_ssid .. '" ' .. hostapd) ~= 0 then
        logger('misconfiguration: did neither find ssid ' .. ssid.ssid .. ' nor ' .. offline_ssid .. '. please reboot')
      end

      local current_ssid = util.trim(util.exec(ssid_grep .. '" ' .. hostapd .. ' | cut -d"=" -f2'))
      -- TODO: replace ~ in current_ssid and ssid.ssid

      logger(msg .. ' - ssid is ' .. current_ssid .. ', change to ' .. ssid.ssid)
      os.execute('sed -i "s~^ssid=' .. current_ssid .. '~ssid=' .. ssid.ssid .. '~" ' .. hostapd)
      hup_needed = 1
    end
  end
elseif check == 0 then
  print("node is considered offline")
  if up < first or m == 0 then
    -- set ssid offline, only if uptime is less than first or exactly a multiplicative of switch_timeframe
    local t = minutes
    if up < first then
      t = first
    end
    if off_count >= t / 2 then
      -- node was offline more times than half of switch_timeframe (or than first)
      for _, ssid in ipairs(ssids) do
        local hostapd = '/var/run/hostapd-' .. ssid.phy .. '.conf'
        local current_ssid = util.trim(util.exec(ssid_grep .. '" ' .. hostapd .. ' | cut -d"=" -f2'))

        -- first grep for offline_ssid in hostapd file
        if os.execute(ssid_grep .. offline_ssid .. '" ' .. hostapd) == 0 then
          print('ssid ' .. current_ssid .. ' is correct')
          break
        else
          -- set offline
          -- debug: grep for online-SSID in hostapd file
          if os.execute(ssid_grep .. ssid.ssid .. '" ' .. hostapd) == 0 then
            logger('misconfiguration: did neither find ssid '
              .. ssid.ssid .. ' nor ' .. offline_ssid .. '. please reboot')
          end

          logger(msg .. ' - ' .. off_count .. ' times offline, ssid is '
            .. current_ssid .. ', change to ' .. offline_ssid)
          os.execute('sed -i "s~^ssid=' .. ssid.ssid .. '~ssid=' .. offline_ssid .. '~" ' .. hostapd)
          hup_needed = 1
        end
      end
    end
    -- else print("minute ' .. m .. ', just count ' .. off_count .. '")
  end

  assert(io.open(tmp, 'w')):write(off_count + 1)
end

if hup_needed == 1 then
  -- send hup to all hostapd to load the new ssid
  os.execute('killall -hup hostapd')
  print("hup!")
end

if m == 0 then
  -- set counter to 0 if the timeframe is over
  assert(io.open(tmp, 'w')):write('0')
end
