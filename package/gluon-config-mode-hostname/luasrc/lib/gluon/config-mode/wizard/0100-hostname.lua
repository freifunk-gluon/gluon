local cbi = require "luci.cbi"
local i18n = require "luci.i18n"
local pretty_hostname = require "pretty_hostname"
local uci = luci.model.uci.cursor()

local M = {}

function M.section(form)
  local s = form:section(cbi.SimpleSection, nil, nil)
  local o = s:option(cbi.Value, "_hostname", i18n.translate("Node name"))
  o.value = pretty_hostname.get(uci)
  o.rmempty = false
end

function M.handle(data)
  pretty_hostname.set(uci, data._hostname)
  uci:commit("system")
end

return M
