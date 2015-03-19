local cbi = require "luci.cbi"
local i18n = require "luci.i18n"
local uci = luci.model.uci.cursor()

local M = {}

function M.section(form)
  local s = form:section(cbi.SimpleSection, nil,
    i18n.translate("If you want your node to be displayed on the map, you can enter its coodinates here."))

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
end

function M.handle(data)
  local sname = uci:get_first("gluon-node-info", "location")

  uci:set("gluon-node-info", sname, "share_location", data._location)
  if data._location and data._latitude ~= nil and data._longitude ~= nil then
    uci:set("gluon-node-info", sname, "latitude", data._latitude)
    uci:set("gluon-node-info", sname, "longitude", data._longitude)
  end
  uci:save("gluon-node-info")
  uci:commit("gluon-node-info")
end

return M
