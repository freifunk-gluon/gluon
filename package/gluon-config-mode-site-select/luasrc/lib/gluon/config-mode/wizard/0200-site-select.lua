local cbi = require "luci.cbi"
local i18n = require "luci.i18n"
local uci = require('luci.model.uci').cursor()
local default = require 'gluon.site_config'
local tools = require 'gluon.site_generate'

local M = {}

function M.section(form)
  local sites = tools.get_config('/lib/gluon/site-select/sites.json')

  local msg = i18n.translate('gluon-config-mode:site-select')
  local s = form:section(cbi.SimpleSection, nil, msg)

  local o = s:option(cbi.ListValue, "community", i18n.translate("Region"))
  o.rmempty = false
  o.optional = false

  if uci:get_first("gluon-setup-mode", "setup_mode", "configured") == "0" then
    o:value("")
  else
    o:value(default.site_code, default.site_name)
  end

  for _, site in pairs(sites) do
    if site.site_select == nil or site.site_select.hidden ~= 1 then
      o:value(site.site_code, site.site_name)
    end
  end
end

function M.handle(data)
  if data.community ~= uci:get('currentsite', 'current', 'name') then
    tools.set_site_code(data.community)
  end

  if data.community ~= default.site_code then
    os.execute('sh "/lib/gluon/site-select/site-upgrade"')
  end
end

return M
