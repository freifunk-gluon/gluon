local cbi = require "luci.cbi"
local i18n = require "luci.i18n"
local uci = luci.model.uci.cursor()
local site = require 'gluon.site_config'

local M = {}

function M.section(form)
  local s = form:section(cbi.SimpleSection, nil, i18n.translate(
    'Please provide your contact information here to '
      .. 'allow others to contact you. Note that '
      .. 'this information will be visible <em>publicly</em> '
      .. 'on the internet together with your node\'s coordinates.'
    )
  )

  local o = s:option(cbi.Value, "_contact", i18n.translate("Contact info"))
  o.default = uci:get_first("gluon-node-info", "owner", "contact", "")
  o.rmempty = not ((site.config_mode or {}).owner or {}).obligatory
  o.datatype = "string"
  o.description = i18n.translate("e.g. E-mail or phone number")
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
