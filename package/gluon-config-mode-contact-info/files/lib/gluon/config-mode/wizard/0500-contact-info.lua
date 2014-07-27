local cbi = require "luci.cbi"
local uci = luci.model.uci.cursor()

local M = {}

function M.section(form)
  local s = form:section(cbi.SimpleSection, nil,
    [[Hier kannst du einen <em>öffentlichen</em> Hinweis hinterlegen um
    anderen Freifunkern zu ermöglichen Kontakt mit dir aufzunehmen. Bitte
    beachte, dass dieser Hinweis auch öffentlich im Internet, zusammen mit
    den Koordinaten deines Knotens, einsehbar sein wird.]])

  local o = s:option(cbi.Value, "_contact", "Kontakt")
  o.default = uci:get_first("gluon-node-info", "owner", "contact", "")
  o.rmempty = true
  o.datatype = "string"
  o.description = "z.B. E-Mail oder Telefonnummer"
  o.maxlen = 140
end

function M.handle(data)
  if data._contact ~= nil then
    uci:set("gluon-node-info", uci:get_first("gluon-node-info", "owner"), "contact", data._contact)
  else
    uci:delete("gluon-node-info", uci:get_first("gluon-node-info", "owner"), "contact")
  end
  uci:save("gluon-node-info")
  uci:commit("gluon-node-info")
end

return M
