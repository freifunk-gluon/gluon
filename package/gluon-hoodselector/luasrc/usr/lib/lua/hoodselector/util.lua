local util = require 'gluon.util'
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

function M.get_domains()
  local list = {}
  for _, domain_path in ipairs(util.glob('/lib/gluon/domains/*.json')) do
    table.insert(list, {
      domain_code = domain_path:match('([^/]+)%.json$'),
      domain = assert(json.load(domain_path)),
    })
  end
  return list
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

-- bool if direct VPN. The detection is realised by searching the fastd network interface inside the originator table
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

-- Get Geoposition. Return nil for no position
function M.getGeolocation()
  return {["lat"] = tonumber(uci:get('gluon-node-info', uci:get_first('gluon-node-info', 'location'), 'latitude')),
  ["lon"] =  tonumber(uci:get('gluon-node-info', uci:get_first('gluon-node-info', 'location'), 'longitude')) }
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
    uci:commit('gluon')
    os.execute('gluon-reconfigure')
    io.stdout:write("Set hood \""..geoHood.domain.domain_names[geoHood.domain_code].."\"\n")
    return true
  end
  return false
end

function M.restart_services()
  local procTBL = {
    "fastd",
    "tunneldigger",
    "network",
    "gluon-respondd",
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

return M
