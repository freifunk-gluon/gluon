local cbi = require "luci.cbi"
local uci = luci.model.uci.cursor()

local M = {}

function M.section(form)
  local s = form:section(cbi.SimpleSection, nil, nil)
  local o = s:option(cbi.Value, "_hostname", "Name dieses Knotens")
  o.value = uci:get_first("system", "system", "hostname")
  o.rmempty = false
  o.datatype = "hostname"
end

function M.handle(data)
  uci:set("system", uci:get_first("system", "system"), "hostname", data._hostname)
  uci:save("system")
  uci:commit("system")
end

return M
