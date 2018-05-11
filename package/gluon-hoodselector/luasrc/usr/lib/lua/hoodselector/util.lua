local fs = require 'nixio.fs'
local json = require 'jsonc'
local uci = require('simple-uci').cursor()
local site = require 'gluon.site'

local M = {}

function M.split(s, delimiter)
  local result = {};
  for match in (s..delimiter):gmatch("(.-)"..delimiter) do
    table.insert(result, match);
  end
  return result;
end

local PID = M.split(io.open("/proc/self/stat", 'r'):read('*a'), " ")[1]

function M.log(msg)
  if msg then
    io.stdout:write(msg.."\n")
    os.execute("logger hoodselector["..PID.."]: "..msg)
  end
end

-- bool if direct VPN. The detection is realaise by searching the fastd network interface inside the originator table
function M.directVPN(vpnIfaceList)
  for _,vpnIface in ipairs(vpnIfaceList) do
    local file = io.open("/sys/kernel/debug/batman_adv/bat0/originators", 'r')
    if file ~= nil then
      for outgoingIF in file:lines() do
        -- escape special chars "[]-"
        if outgoingIF:match(string.gsub("%[  " .. vpnIface .. "%]","%-", "%%-")) then
          return true
        end
      end
    end
  end
  return false
end

function M.fastd_installed()
  if io.open("/usr/bin/fastd", 'r') ~= nil then
    return true
  end
  return false
end

function M.tunneldigger_installed()
  if io.open("/usr/bin/tunneldigger", 'r') ~= nil then
    return true
  end
  return false
end

-- Get Geoposition. Return nil for no position
function M.getGeolocation()
  return {["lat"] = tonumber(uci:get('gluon-node-info', uci:get_first('gluon-node-info', 'location'), 'latitude')),
  ["lon"] =  tonumber(uci:get('gluon-node-info', uci:get_first('gluon-node-info', 'location'), 'longitude')) }
end

function M.get_domains()
  local list = {}
  for domain_path in fs.glob('/lib/gluon/domains/*.json') do
    table.insert(list, {
      domain_code = domain_path:match('([^/]+)%.json$'),
      domain = assert(json.load(domain_path)),
    })
  end
  return list
end

-- Source with pseudocode: https://de.wikipedia.org/wiki/Punkt-in-Polygon-Test_nach_Jordan
-- see also https://en.wikipedia.org/wiki/Point_in_polygon
-- parameters: points A = (x_A,y_A), B = (x_B,y_B), C = (x_C,y_C)
-- return value: −1 if the ray from A to the right bisects the edge [BC] (the lower vortex of [BC]
-- is not seen as part of [BC]);
--                0 if A is on [BC];
--               +1 else
function M.crossProdTest(x_A,y_A,x_B,y_B,x_C,y_C)
  if y_A == y_B and y_B == y_C then
    if (x_B <= x_A and x_A <= x_C) or (x_C <= x_A and x_A <= x_B) then
      return 0
    end
    return 1
  end
  if not ((y_A == y_B) and (x_A == x_B)) then
    if y_B > y_C then
      -- swap B and C
      local h = x_B
      x_B = x_C
      x_C = h
      h = y_B
      y_B = y_C
      y_C = h
    end
    if (y_A <= y_B) or (y_A > y_C) then
      return 1
    end
    local Delta = (x_B-x_A) * (y_C-y_A) - (y_B-y_A) * (x_C-x_A)
    if Delta > 0 then
      return 1
    elseif Delta < 0 then
      return -1
    end
  end
  return 0
end

-- Source with pseudocode: https://de.wikipedia.org/wiki/Punkt-in-Polygon-Test_nach_Jordan
-- see also: https://en.wikipedia.org/wiki/Point_in_polygon
-- let P be a 2D Polygon and Q a 2D Point
-- return value:  +1 if Q within P;
--               −1 if Q outside of P;
--                0 if Q on an edge of P
function M.pointInPolygon(poly, point)
  local t = -1
  for i=1,#poly-1 do
    t = t * M.crossProdTest(point.lon,point.lat,poly[i].lon,poly[i].lat,poly[i+1].lon,poly[i+1].lat)
    if t == 0 then break end
  end
  return t
end

-- Return hood from the hood file based on geo position or nil if no real hood could be determined
-- First check if an area has > 2 points and is hence a polygon. Else assume it is a rectangular
-- box defined by two points (south-west and north-east)
function M.getHoodByGeo(jhood,geo)
  for _, hood in pairs(jhood) do
    if hood.domain_code ~= site.default_domain() then
    for _, area in pairs(hood.domain.hoodselector.shapes) do
      if #area > 2 then
        if (M.pointInPolygon(area,geo) == 1) then
          return hood
        end
      else
        if ( geo.lat >= area[1].lat and geo.lat < area[2].lat and geo.lon >= area[1].lon
          and geo.lon < area[2].lon ) then
          return hood
        end
      end
    end
    end
  end
  return nil
end

function M.set_hoodconfig(geoHood)
  if uci:get('gluon', 'core', 'domain') ~= geoHood.domain_code then
    uci:set('gluon', 'core', 'domain', geoHood.domain_code)
    uci:save('gluon')
    uci:commit('gluon') -- necessary?
    os.execute('gluon-reconfigure')
    io.stdout:write("Set hood \""..geoHood.domain.domain_names[geoHood.domain_code].."\"\n")
    return true
  end
  return false
end

-- Return the default hood in the hood list.
-- This method can return the following data:
-- * default hood
-- * nil if no default hood has been defined
function M.getDefaultHood(jhood)
  for _, h in pairs(jhood) do
    if h.domain_code == site.default_domain() then
      return h
    end
  end
  return nil
end

function M.restart_services()
  local procTBL = {
    "fastd",
    "tunneldigger",
    "network",
  }

  for proc in ipairs(procTBL) do
    if io.open("/etc/init.d/"..proc, 'r') ~= nil then
      print(proc.." restarting ...")
      os.execute("/etc/init.d/"..proc.." restart")
    end
  end
  if io.open("/etc/config/wireless", 'r') then
    print("wifi restarting ...")
    os.execute("wifi")
  end
end

function M.trim(s)
  -- from PiL2 19.4
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

--[[function M.get_batman_GW_interface()
  for gw in io.open("/sys/kernel/debug/batman_adv/bat0/gateways", 'r'):lines() do
    if gw:match("=>") then
      return M.trim(gw:match("%[.-%]"):gsub("%[", ""):gsub("%]", ""))
    end
  end
  return nil
end]]

-- Get a list of wifi devices return an emty table for no divices
function M.getWifiDevices()
  local radios = {}
  uci:foreach('wireless', 'wifi-device',
  function(s)
    table.insert(radios, s['.name'])
  end
  )
  return radios
end

function M.matchID(tp, h, ID)
  if h.domain.wifi24 ~= nil then
    if tp == "ibss" then
      if h.domain.wifi24.ibss ~= nil then
        if h.domain.wifi24.ibss.bssid ~= nil then
          if ID:lower() == h.domain.wifi24.ibss.bssid:lower() then
            return true
          end
        end
      end
    end
    if tp == "11s" then
      if h.domain.wifi24.mesh ~= nil then
        if h.domain.wifi24.mesh.id ~= nil then
          if ID:lower() == h.domain.wifi24.mesh.id:lower() then
            return true
          end
        end
      end
    end
  elseif h.domain.wifi5 ~= nil then
    if tp == "ibss" then
      if h.domain.wifi5.ibss ~= nil then
        if h.domain.wifi5.ibss.bssid ~= nil then
          if ID:lower() == h.domain.wifi5.ibss.bssid:lower() then
            return true
          end
        end
      end
    end
    if tp == "11s" then
      if h.domain.wifi5.mesh ~= nil then
        if h.domain.wifi5.mesh.id ~= nil then
          if ID:lower() == h.domain.wifi5.mesh.id:lower() then
            return true
          end
        end
      end
    end
  end
  return false
end

-- Return hood from the hood file based on a given BSSID. nil if no matching hood could be found
function M.gethoodByBssid(jhood, bssid)
  for _, h in pairs(jhood) do
    if M.matchID("ibss", h, bssid) then
      return h
    end
  end
  return nil
end

function M.gethoodByMeshID(jhood, meshid)
  for _, h in pairs(jhood) do
    if M.matchID("11s", h, meshid) then
      return h
    end
  end
  return nil
end

function M.getHoodByRadio(iface,jhood)
  for _, radio in ipairs(M.getWifiDevices()) do
    local ifname = uci:get('wireless', 'ibss_' .. radio, 'ifname')
    if ifname == iface then
      return M.gethoodByBssid(jhood, uci:get('wireless', 'ibss_' .. radio, 'bssid'))
    end
    ifname = uci:get('wireless', 'mesh_' .. radio, 'ifname')
    if ifname == iface then
      return M.gethoodByMeshID(jhood, uci:get('wireless', 'mesh_' .. radio, 'mesh_id'))
    end
  end
  return nil
end

-- get signal strength
function M.scan_filter_quality(scan_str, redirect)
  local tmp_quality = redirect
  if scan_str:match("signal:") then
    tmp_quality = M.split(scan_str, " ")[2]
    tmp_quality = M.split(tmp_quality, "%.")[1]
    if tmp_quality:match("-") then
      tmp_quality = M.split(tmp_quality, "-")[2]
    end
    tmp_quality = tonumber(tmp_quality:match("(%d%d)"))
  end
  return tmp_quality
end

function M.ibss_scan(radio,ifname,networks)
  local wireless_scan = string.format("iw %s scan", ifname)
  local row = {}
  local isIBSS = ""
  row["radio"] = radio
  row["method"] = "ibss"
  -- loop through each line in the output of iw
  for wifiscan in io.popen(wireless_scan, 'r'):lines() do
    wifiscan = M.trim(wifiscan)
    -- get bssid
    if wifiscan:match("BSS (%w+:%w+:%w+:%w+:%w+:%w+)") then
      row["bssid"] = wifiscan:match("(%w+:%w+:%w+:%w+:%w+:%w+)")
      row["frequency"] = nil
      isIBSS = ""
      row["quality"] = nil
      row["ssid"] = nil
    end

    -- get frequency
    if wifiscan:match("freq") then
      row["frequency"] = M.split(wifiscan, ":")[2]
      if row["frequency"] ~= nil then
        row["frequency"] = M.trim(row["frequency"])
        isIBSS = ""
        row["quality"] = nil
        row["ssid"] = nil
      end
    end

    --get ibss capability
    if wifiscan:match("capability:") then
      isIBSS = M.split(wifiscan, ':')[2]
      isIBSS = M.split(isIBSS, ' ')[2]
      if(isIBSS ~= nil) then
        isIBSS = M.trim(isIBSS)
        row["quality"] = nil
        row["ssid"] = nil
      end
    end

    row["quality"] = M.scan_filter_quality(wifiscan, row["quality"])

    -- get ssid
    if wifiscan:match("SSID:") then
      row["ssid"] = M.split(wifiscan, "SSID:")[2]
      if(row["ssid"] ~= nil) then
        row["ssid"] = M.trim(row["ssid"])
      end
    end

    -- the following line matches a new network in the output of iw
    if (row["bssid"] ~= nil and row["quality"] ~= nil and row["ssid"] ~= nil
      and row["frequency"] ~= nil and isIBSS == "IBSS") then
      table.insert(networks, row)
      row = {}
      row["radio"] = radio
      row["method"] = "ibss"
      isIBSS = ""
    end
  end
  return networks
end

function M.mesh_scan(radio,ifname,networks)
  local wireless_scan = string.format("iw %s scan", ifname)
  local row = {}
  row["radio"] = radio
  row["method"] = "11s"
  -- loop through each line in the output of iw
  for wifiscan in io.popen(wireless_scan, 'r'):lines() do
    wifiscan = M.trim(wifiscan)

    -- get frequency
    if wifiscan:match("freq") then
      row["frequency"] = M.split(wifiscan, ":")[2]
      if row["frequency"] ~= nil then
        row["frequency"] = M.trim(row["frequency"])
        row["quality"] = nil
        row["meshid"] = nil
      end
    end

    row["quality"] = M.scan_filter_quality(wifiscan, row["quality"])

    -- get mesh-ID
    if wifiscan:match("MESH ID:") then
      row["meshid"] = M.split(wifiscan, "MESH ID:")[2]
      if row["meshid"] ~= nil then
        row["meshid"] = M.trim(row["meshid"])
      end
    end
    -- the following line matches a new network in the output of iw
    if(row["meshid"] ~= nil and row["quality"] ~= nil and row["frequency"] ~= nil) then
      table.insert(networks, row)
      row = {}
      row["radio"] = radio
      row["method"] = "11s"
    end
  end
  return networks
end

-- Scans for wireless networks and returns a two dimensional array containing
-- wireless mesh neighbour networks and their properties.
-- The array is sorted descending by signal strength (strongest signal
-- first, usually the local signal of the wireless chip of the router)
function M.wlan_list_sorted()
  local networks = {}
  for _, radio in ipairs(M.getWifiDevices()) do
    local ifname = uci:get('wireless', 'ibss_' .. radio, 'ifname')
    if ifname ~= nil then
      --do ibss scan
      networks = M.ibss_scan(radio,ifname,networks)
    end
    ifname = uci:get('wireless', 'mesh_' .. radio, 'ifname')
    if ifname ~= nil then
      --do mesh scan
      networks = M.mesh_scan(radio,ifname,networks)
    end
  end
  if next(networks) then
    table.sort(networks, function(a,b) return a["quality"] < b["quality"] end)
  end
  return networks
end

function M.filter_default_hood_wlan_networks(default_hood, wlan_list)
  for i=#wlan_list,1,-1 do
    if wlan_list[i].method == "ibss" then
      if M.matchID("ibss", default_hood, wlan_list[i].bssid) then
        table.remove(wlan_list, i)
      end
    elseif wlan_list[i].method == "11s" then
      if M.matchID("11s", default_hood, wlan_list[i].meshid) then
        table.remove(wlan_list, i)
      end
    end
  end
  return wlan_list
end

function M.filter_wlan_redundancy(list)
  local flag = {}
  local ret = {}
  for _, element in ipairs(list) do
    if element.method == "ibss" then
      if not flag[element.bssid] then
        ret[#ret+1] = element
        flag[element.bssid] = true
      end
    end
    if element.method == "11s" then
      if not flag[element.meshid] then
        ret[#ret+1] = element
        flag[element.meshid] = true
      end
    end
  end
  return ret
end

-- this method removes the wireless network of the router itself
-- from the wlan_list
function M.filter_my_wlan_network(wlan_list)
  for i=#wlan_list,1,-1 do
    local bssid = uci:get('wireless', 'ibss_' .. wlan_list[i].radio, 'bssid')
    if bssid ~= nil and wlan_list[i].method == "ibss" then
      if string.lower(wlan_list[i].bssid) == string.lower(bssid) then
        table.remove(wlan_list, i)
      end
    else
      local mesh = uci:get('wireless', 'mesh_' .. wlan_list[i].radio, 'mesh_id')
      if mesh ~= nil and wlan_list[i].method == "11s" then
        if string.lower(wlan_list[i].meshid) == string.lower(mesh) then
          table.remove(wlan_list, i)
        end
      end
    end
  end
  return wlan_list
end

function M.fastd_installed()
  if io.open("/usr/bin/fastd", 'r') ~= nil then
    return true
  end
  return false
end

function M.tunneldigger_installed()
  if io.open("/usr/bin/tunneldigger", 'r') ~= nil then
    return true
  end
  return false
end

function M.vpn_stop()
  -- check if fastd installed
  if M.fastd_installed() then
    if uci:get_bool('fastd','mesh_vpn','enabled') then
      os.execute('/etc/init.d/fastd stop')
      io.stdout:write('Fastd stoped.\n')
    end
  end
  -- check if tunneldigger installed
  if M.tunneldigger_installed() then
    if uci:get_bool('tunneldigger','mesh_vpn','enabled') then
      os.execute('/etc/init.d/tunneldigger stop')
      io.stdout:write('Tunneldigger stoped.\n')
    end
  end
end

-- boolean check if batman-adv has gateways
function M.batmanHasGateway()
  local file = io.open("/sys/kernel/debug/batman_adv/bat0/gateways", 'r')
  if file ~= nil then
    for gw in file:lines() do
      if gw:match("Bit") then
        return true
      end
    end
  end
  return false
end

function M.sleep(n)
  os.execute("sleep " .. tonumber(n))
end

function M.test_batman_mesh_networks(sorted_wlan_list)
  -- remove the ap network(s) because we cannot change
  -- the settings of the adhoc network if a ap network is still operating
  for iface in io.popen(string.format("iw dev"),'r'):lines() do
    if iface:match("Interface") then
      iface = M.trim(M.split(iface, "Interface")[2])
      if not ( iface:match("ibss") or iface:match("mesh")) then
        os.execute("iw dev "..iface.." del")
      end
    end
  end
  for _, wireless in pairs(sorted_wlan_list) do
    local ibss = uci:get('wireless', 'ibss_' .. wireless["radio"], 'ifname')
    local mesh = uci:get('wireless', 'mesh_' .. wireless["radio"], 'ifname')
    if wireless.method == "ibss" then
      io.stdout:write("Testing IBSS "..wireless["bssid"].."...\n")
      -- leave the current adhoc network
      os.execute("iw dev "..ibss.." ibss leave 2> /dev/null")
      -- leave mesh as well to avoid hood shortcuts while testing
      if mesh ~= nil then
        os.execute("iw dev "..mesh.." mesh leave 2> /dev/null")
      end
      -- setup the adhoc network we want to test
      os.execute("iw dev "..ibss.." ibss join "..uci:get('wireless', 'ibss_'..
      wireless["radio"], 'ssid').." "..wireless["frequency"].." "..wireless["bssid"])
    end
    if wireless.method == "11s" then
      io.stdout:write("Testing MESH "..wireless["meshid"].."...\n")
      -- leave the current mesh network
      os.execute("iw dev "..mesh.." mesh leave 2> /dev/null")
      if ibss ~= nil then
        os.execute("iw dev "..ibss.." ibss leave 2> /dev/null")
      end
      -- setup the mesh network we want to test
      os.execute("iw dev "..mesh.." mesh join "..wireless["meshid"].." freq "..wireless["frequency"])
    end
    -- sleep 30 seconds till the connection is fully setup
    local c = 0;
    while(not M.batmanHasGateway()) do
      if(c >= 30) then break end
      M.sleep(1)
      c = c +1;
    end
    if c < 30 then
      local msg = "found gateways on: "
      local ret = {}
      if wireless.method == "ibss" then
        ret["method"] = "ibss"
        ret["bssid"] = wireless["bssid"]
        print(msg..ret["bssid"])
        return ret
      end
      if wireless.method == "11s" then
        ret["method"] = "11s"
        ret["meshid"] = wireless["meshid"]
        print(msg..ret["meshid"])
        return ret
      end
    end
  end
  return nil
end

function M.brclient_restart()
  os.execute('ifconfig br-client down')
  os.execute('ifconfig br-client up')
  io.stdout:write('Interface br-client restarted.\n')
end

function M.vpn_start()
  if M.fastd_installed() then
    if uci:get_bool('fastd','mesh_vpn','enabled') then
      os.execute('/etc/init.d/fastd start')
      io.stdout:write('Fastd started.\n')
    end
  end
  if M.tunneldigger_installed() then
    if uci:get_bool('tunneldigger','mesh_vpn','enabled') then
      os.execute('/etc/init.d/tunneldigger start')
      io.stdout:write('Tunneldigger started.\n')
    end
  end
  M.brclient_restart()
end

function M.wireless_restart()
  os.execute('wifi')
  io.stdout:write('Wireless restarted.\n')
end

function M.get_batman_mesh_network(sorted_wlan_list, defaultHood)
  io.stdout:write('Testing neighbouring adhoc networks for batman advanced gw connection.\n')
  io.stdout:write('The following wireless networks have been found:\n')
  for _, network in pairs(sorted_wlan_list) do
    if network["method"] == "ibss" then
      print(network["quality"].."\t"..network["method"].."\t"..network["radio"]..
      "\t"..network["ssid"].."\t"..network["bssid"].."\t"..network["frequency"])
    end
    if network["method"] == "11s" then
      print(network["quality"].."\t"..network["method"].."\t"..network["radio"]..
      "\t"..network["meshid"].."\t"..network["frequency"])
    end
  end

  -- we dont want to test the default hood because if there is no other
  -- hood present we will connect to the default hood anyway
  sorted_wlan_list = M.filter_default_hood_wlan_networks(defaultHood, sorted_wlan_list)
  -- we dont want to test duplicated networks
  sorted_wlan_list = M.filter_wlan_redundancy(sorted_wlan_list)
  -- we dont want to get tricked by our signal
  sorted_wlan_list = M.filter_my_wlan_network(sorted_wlan_list)

  io.stdout:write('After filtering we will test the following wireless networks:\n')
  for _, network in pairs(sorted_wlan_list) do
    if network["method"] == "ibss" then
      print(network["quality"].."\t"..network["method"].."\t"..network["radio"].."\t"..
      network["ssid"].."\t    "..network["bssid"].."\t"..network["frequency"])
    end
    if network["method"] == "11s" then
      print(network["quality"].."\t"..network["method"].."\t"..network["radio"].."\t"..
      network["meshid"].."    \t"..network["frequency"])
    end
  end

  local ID = nil
  if(next(sorted_wlan_list)) then
    io.stdout:write("Prepare configuration for testing wireless networks...\n")
    -- Notice:
    -- we will use iw for testing the wireless networks because using iw does
    -- not need any changes inside the uci config. This approach allows the
    -- router to automatically reset to previous configuration in case
    -- someone disconnects the router from power during test.

    -- stop vpn to prevent two hoods from beeing connected in case
    -- the router gets internet unexpectedly during test.
    M.vpn_stop()
    ID = M.test_batman_mesh_networks(sorted_wlan_list)
    M.vpn_start()
    M.wireless_restart()
    io.stdout:write("Finished testing wireless networks, restored previous configuration\n")
  end

  return ID
end

function M.vpn_disable()
  if M.fastd_installed() then
    if uci:get_bool('fastd','mesh_vpn','enabled') then
      os.execute('/etc/init.d/fastd disable')
      io.stdout:write('Fastd disabled.\n')
    end
  end
  if M.tunneldigger_installed() then
    if uci:get_bool('tunneldigger','mesh_vpn','enabled') then
      os.execute('/etc/init.d/tunneldigger disable')
      io.stdout:write('Tunneldigger disabled.\n')
    end
  end
end

return M
