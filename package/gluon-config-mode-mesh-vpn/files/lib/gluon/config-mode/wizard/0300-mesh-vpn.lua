local cbi = require "luci.cbi"
local uci = luci.model.uci.cursor()

local M = {}

function M.section(form)
  local s = form:section(cbi.SimpleSection, nil,
    [[Falls du deinen Knoten über das Internet mit Freifunk verbinden
    möchtest, kannst du hier das Mesh-VPN aktivieren.  Solltest du dich
    dafür entscheiden, hast du die Möglichkeit die dafür genutzte
    Bandbreite zu beschränken. Lässt du das Mesh-VPN deaktiviert,
    verbindet sich dein Knoten nur per WLAN mit anderen Knoten in der
    Nähe.]])

  local o

  o = s:option(cbi.Flag, "_meshvpn", "Mesh-VPN aktivieren")
  o.default = uci:get_bool("fastd", "mesh_vpn", "enabled") and o.enabled or o.disabled
  o.rmempty = false

  o = s:option(cbi.Flag, "_limit_enabled", "Mesh-VPN Bandbreite begrenzen")
  o:depends("_meshvpn", "1")
  o.default = uci:get_bool("gluon-simple-tc", "mesh_vpn", "enabled") and o.enabled or o.disabled
  o.rmempty = false

  o = s:option(cbi.Value, "_limit_ingress", "Downstream (kbit/s)")
  o:depends("_limit_enabled", "1")
  o.value = uci:get("gluon-simple-tc", "mesh_vpn", "limit_ingress")
  o.rmempty = false
  o.datatype = "integer"

  o = s:option(cbi.Value, "_limit_egress", "Upstream (kbit/s)")
  o:depends("_limit_enabled", "1")
  o.value = uci:get("gluon-simple-tc", "mesh_vpn", "limit_egress")
  o.rmempty = false
  o.datatype = "integer"
end

function M.handle(data)
  uci:set("fastd", "mesh_vpn", "enabled", data._meshvpn)
  uci:save("fastd")
  uci:commit("fastd")

  -- checks for nil needed due to o:depends(...)
  if data._limit_enabled ~= nil then
    uci:set("gluon-simple-tc", "mesh_vpn", "interface")
    uci:set("gluon-simple-tc", "mesh_vpn", "enabled", data._limit_enabled)
    uci:set("gluon-simple-tc", "mesh_vpn", "ifname", "mesh-vpn")

    if data._limit_ingress ~= nil then
      uci:set("gluon-simple-tc", "mesh_vpn", "limit_ingress", data._limit_ingress)
    end

    if data._limit_egress ~= nil then
      uci:set("gluon-simple-tc", "mesh_vpn", "limit_egress", data._limit_egress)
    end

    uci:commit("gluon-simple-tc")
    uci:commit("gluon-simple-tc")
  end
end

return M
