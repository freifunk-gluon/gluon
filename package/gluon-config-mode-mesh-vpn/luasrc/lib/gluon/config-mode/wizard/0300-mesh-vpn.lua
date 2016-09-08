local cbi = require "luci.cbi"
local i18n = require "luci.i18n"
local uci = luci.model.uci.cursor()

local M = {}

function M.section(form)
  local msg = i18n.translate('Your internet connection can be used to establish an ' ..
                             'encrypted connection with other nodes. ' ..
                             'Enable this option if there are no other nodes reachable ' ..
                             'over WLAN in your vicinity or you want to make a part of ' ..
                             'your connection\'s bandwidth available for the network. You can limit how ' ..
                             'much bandwidth the node will use at most.')
  local s = form:section(cbi.SimpleSection, nil, msg)

  local o

  o = s:option(cbi.Flag, "_meshvpn", i18n.translate("Use internet connection (mesh VPN)"))
  o.default = uci:get_bool("fastd", "mesh_vpn", "enabled") and o.enabled or o.disabled
  o.rmempty = false

  o = s:option(cbi.Flag, "_limit_enabled", i18n.translate("Limit bandwidth"))
  o:depends("_meshvpn", "1")
  o.default = uci:get_bool("simple-tc", "mesh_vpn", "enabled") and o.enabled or o.disabled
  o.rmempty = false

  o = s:option(cbi.Value, "_limit_ingress", i18n.translate("Downstream (kbit/s)"))
  o:depends("_limit_enabled", "1")
  o.value = uci:get("simple-tc", "mesh_vpn", "limit_ingress")
  o.rmempty = false
  o.datatype = "uinteger"

  o = s:option(cbi.Value, "_limit_egress", i18n.translate("Upstream (kbit/s)"))
  o:depends("_limit_enabled", "1")
  o.value = uci:get("simple-tc", "mesh_vpn", "limit_egress")
  o.rmempty = false
  o.datatype = "uinteger"
end

function M.handle(data)
  uci:set("fastd", "mesh_vpn", "enabled", data._meshvpn)
  uci:save("fastd")
  uci:commit("fastd")

  -- checks for nil needed due to o:depends(...)
  if data._limit_enabled ~= nil then
    uci:set("simple-tc", "mesh_vpn", "interface")
    uci:set("simple-tc", "mesh_vpn", "enabled", data._limit_enabled)
    uci:set("simple-tc", "mesh_vpn", "ifname", "mesh-vpn")

    if data._limit_ingress ~= nil then
      uci:set("simple-tc", "mesh_vpn", "limit_ingress", data._limit_ingress:trim())
    end

    if data._limit_egress ~= nil then
      uci:set("simple-tc", "mesh_vpn", "limit_egress", data._limit_egress:trim())
    end

    uci:save("simple-tc")
    uci:commit("simple-tc")
  end
end

return M
