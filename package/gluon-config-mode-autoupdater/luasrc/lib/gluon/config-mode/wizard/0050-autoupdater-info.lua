local cbi = require "luci.cbi"
local i18n = require "luci.i18n"
local uci = luci.model.uci.cursor()

local M = {}

function M.section(form)
  local enabled = uci:get_bool("autoupdater", "settings", "enabled")
  if enabled then
    form:section(cbi.SimpleSection, nil,
      i18n.translate('This node will automatically update its firmware when a new version is available.'))
  else
    form:section(cbi.SimpleSection, nil,
      i18n.translate("Automatic updates are disabled. They can be enabled in <em>Advanced settings</em>"))
  end
end

function M.handle(data)
  return
end

return M
