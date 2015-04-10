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

  local msg = [[<p>]] .. i18n.translate('gluon-config-mode:pubkey') .. [[</p>
               <div class="the-key">
                 # <%= hostname %>
                 <br/>
               <%= pubkey %>
               </div>]]

  return function ()
           luci.template.render_string(msg, { pubkey=pubkey
                                            , hostname=hostname
                                            , site=site
                                            , sysconfig=sysconfig
                                            })
         end
end
