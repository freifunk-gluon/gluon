local util = require 'gluon.util'
local json = require 'jsonc'
local uci = require('simple-uci').cursor()
local site = require 'gluon.site'
local vpn_util = require('gluon.mesh-vpn')
local logger = require('posix.syslog')
local M = {}

function M.split(s, delimiter)
  local result = {}
  for match in (s..delimiter):gmatch("(.-)"..delimiter) do
    table.insert(result, match)
  end
  return result
end

function M.log(msg)
  io.stdout:write(msg..'\n')
  logger.openlog(msg, logger.LOG_PID)
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
function M.get_default_hood(jhood)
  for _, h in pairs(jhood) do
    if h.domain_code == site.default_domain() then
      return h
    end
  end
  return nil
end

-- bool if direct VPN. The detection is realised by searching the fastd network interface inside the originator table
function M.direct_vpn()
  for outgoing_if in io.popen(string.format("batctl o"), 'r'):lines() do
    -- escape special chars "[]-"
    if outgoing_if:match(string.gsub("%[  " .. vpn_util.get_mesh_vpn_interface() .. "%]","%-", "%%-")) then
      return true
    end
  end
  return false
end

-- Get Geoposition. Return nil for no position
function M.get_geolocation()
  return {
    lat = tonumber(uci:get('gluon-node-info', uci:get_first('gluon-node-info', 'location'), 'latitude')),
    lon = tonumber(uci:get('gluon-node-info', uci:get_first('gluon-node-info', 'location'), 'longitude'))
  }
end

-- Source with pseudocode: https://de.wikipedia.org/wiki/Punkt-in-Polygon-Test_nach_Jordan
-- see also https://en.wikipedia.org/wiki/Point_in_polygon
-- parameters: points A = (x_a,y_a), B = (x_b,y_b), C = (x_c,y_c)
-- return value: −1 if the ray from A to the right bisects the edge [BC] (the lower vortex of [BC]
-- is not seen as part of [BC]);
--                0 if A is on [BC];
--               +1 else
function M.cross_prod_test(x_a,y_a,x_b,y_b,x_c,y_c)
  if y_a == y_b and y_b == y_c then
    if (x_b <= x_a and x_a <= x_c) or (x_c <= x_a and x_a <= x_b) then
      return 0
    end
    return 1
  end
  if not ((y_a == y_b) and (x_a == x_b)) then
    if y_b > y_c then
      -- swap b and c
      local h = x_b
      x_b = x_c
      x_c = h
      h = y_b
      y_b = y_c
      y_c = h
    end
    if (y_a <= y_b) or (y_a > y_c) then
      return 1
    end
    local delta = (x_b-x_a) * (y_c-y_a) - (y_b-y_a) * (x_c-x_a)
    if delta > 0 then
      return 1
    elseif delta < 0 then
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
function M.point_in_polygon(poly, point)
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
function M.get_hood_by_geo(jhood,geo)
  for _, hood in pairs(jhood) do
    if hood.domain_code ~= site.default_domain() then
    for _, area in pairs(hood.domain.hoodselector.shapes) do
      if #area > 2 then
        if (M.point_in_polygon(area,geo) == 1) then
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

function M.set_hoodconfig(geo_hood)
  if uci:get('gluon', 'core', 'domain') ~= geo_hood.domain_code then
    uci:set('gluon', 'core', 'domain', geo_hood.domain_code)
    uci:commit('gluon')
    os.execute('gluon-reconfigure')
    M.log('Set domain "'..geo_hood.domain.domain_names[geo_hood.domain_code]..'"')
    return true
  end
  return false
end

function M.restart_services()
  local proc_tbl = {
    "fastd",
    "tunneldigger",
    "network",
    "gluon-respondd",
  }

  for proc in ipairs(proc_tbl) do
    if io.open("/etc/init.d/"..proc, 'r') ~= nil then
      print(proc.." restarting ...")
      os.execute("/etc/init.d/"..proc.." restart")
    end
  end
end

return M
