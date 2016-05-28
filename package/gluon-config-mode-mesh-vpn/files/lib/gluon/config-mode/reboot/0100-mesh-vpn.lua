local uci = luci.model.uci.cursor()
local meshvpn_enabled = uci:get("fastd", "mesh_vpn", "enabled", "0")

if meshvpn_enabled ~= "1" then
  return nil
else
  local i18n = require "luci.i18n"
  local util = require "luci.util"
  local site = require 'gluon.site_config'
  local sysconfig = require 'gluon.sysconfig'

  local pubkey = util.trim(util.exec("/etc/init.d/fastd show_key " .. "mesh_vpn"))
  local hostname = uci:get_first("system", "system", "hostname")
  local contact = uci:get_first("gluon-node-info", "owner", "contact")

  local msg = i18n.translate('gluon-config-mode:pubkey')

  return function ()
           luci.template.render_string(msg, { pubkey=pubkey
                                            , hostname=hostname
                                            , site=site
                                            , sysconfig=sysconfig
                                            , contact=contact
                                            })
         end
end
