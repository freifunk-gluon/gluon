local cbi = require "luci.cbi"
local i18n = require "luci.i18n"
local uci = luci.model.uci.cursor()
local site = require 'gluon.site_config'

local M = {}

local function show_altitude()
  if ((site.config_mode or {}).geo_location or {}).show_altitude ~= false then
    return true
  end
  if uci:get_first("gluon-node-info", "location", "altitude") then
    return true
  end
  return false
end

function M.section(form)
  local text = i18n.translate('If you want the location of your node to '
    .. 'be displayed on the map, you can enter its coordinates here.')
  if show_altitude() then
    text = text .. ' ' .. i18n.translate('Specifying the altitude is '
      .. 'optional and should only be done if a proper value is known.')
  end
  local s = form:section(cbi.SimpleSection, nil, text)


  local o

  o = s:option(cbi.Flag, "_location", i18n.translate("Show node on the map"))
  o.default = uci:get_first("gluon-node-info", "location", "share_location", o.disabled)
  o.rmempty = false

  o = s:option(cbi.Value, "_latitude", i18n.translate("Latitude"))
  o.default = uci:get_first("gluon-node-info", "location", "latitude")
  o:depends("_location", "1")
  o.rmempty = false
  o.datatype = "float"
  o.description = i18n.translatef("e.g. %s", "53.873621")

  o = s:option(cbi.Value, "_longitude", i18n.translate("Longitude"))
  o.default = uci:get_first("gluon-node-info", "location", "longitude")
  o:depends("_location", "1")
  o.rmempty = false
  o.datatype = "float"
  o.description = i18n.translatef("e.g. %s", "10.689901")

  if show_altitude() then
    o = s:option(cbi.Value, "_altitude", i18n.translate("Altitude"))
    o.default = uci:get_first("gluon-node-info", "location", "altitude")
    o:depends("_location", "1")
    o.rmempty = true
    o.datatype = "float"
    o.description = i18n.translatef("e.g. %s", "11.51")
  end

end

function M.handle(data)
  local sname = uci:get_first("gluon-node-info", "location")

  uci:set("gluon-node-info", sname, "share_location", data._location)
  if data._location and data._latitude ~= nil and data._longitude ~= nil then
    uci:set("gluon-node-info", sname, "latitude", data._latitude:trim())
    uci:set("gluon-node-info", sname, "longitude", data._longitude:trim())
    if data._altitude ~= nil then
      uci:set("gluon-node-info", sname, "altitude", data._altitude:trim())
    else
      uci:delete("gluon-node-info", sname, "altitude")
    end
  end
  uci:save("gluon-node-info")
  uci:commit("gluon-node-info")
end

return M
