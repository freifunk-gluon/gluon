local i18n = require 'luci.i18n'
local site = require 'gluon.site_config'
local gluon_luci = require 'gluon.luci'
local sysconfig = require 'gluon.sysconfig'
local pretty_hostname = require 'pretty_hostname'

local uci = luci.model.uci.cursor()

local hostname = pretty_hostname.get(uci)
local contact = uci:get_first('gluon-node-info', 'owner', 'contact')

local msg = i18n.translate('gluon-config-mode:reboot')

return function ()
  luci.template.render_string(msg, {
    hostname = hostname,
    site = site,
    sysconfig = sysconfig,
    contact = contact,
    escape = gluon_luci.escape,
    urlescape = gluon_luci.urlescape,
  })
end
