local uci = luci.model.uci.cursor()
local meshvpn_enabled = uci:get("fastd", "mesh_vpn", "enabled", "0")

local i18n = require "luci.i18n"
local util = require "luci.util"

local gluon_luci = require 'gluon.luci'
local site = require 'gluon.site_config'
local sysconfig = require 'gluon.sysconfig'

local pretty_hostname = require 'pretty_hostname'

local pubkey = ""
local hostname = pretty_hostname.get(uci)
local contact = uci:get_first("gluon-node-info", "owner", "contact")

local msg = ""
if meshvpn_enabled ~= "1" then
  msg = i18n.translate('gluon-config-mode:novpn')
else
  pubkey = util.trim(util.exec("/etc/init.d/fastd show_key " .. "mesh_vpn"))
  msg = i18n.translate('gluon-config-mode:pubkey')
end

return function ()
  luci.template.render_string(msg, {
    pubkey = pubkey,
    hostname = hostname,
    site = site,
    sysconfig = sysconfig,
    contact = contact,
    escape = gluon_luci.escape,
    urlescape = gluon_luci.urlescape,
  })
end
