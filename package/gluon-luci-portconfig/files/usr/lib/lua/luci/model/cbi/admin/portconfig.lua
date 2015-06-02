--[[
LuCI - Lua Configuration Interface

Copyright 2014 Nils Schneider <nils@nilsschneider.net>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--

local uci = luci.model.uci.cursor()
local sysconfig = require 'gluon.sysconfig'

local wan = uci:get_all("network", "wan")
local wan6 = uci:get_all("network", "wan6")
local dns = uci:get_first("gluon-wan-dnsmasq", "static")

local f = SimpleForm("portconfig", translate("WAN connection"))
f.template = "admin/expertmode"

local s
local o

s = f:section(SimpleSection, nil, nil)

o = s:option(ListValue, "ipv4", translate("IPv4"))
o:value("dhcp", translate("Automatic (DHCP)"))
o:value("static", translate("Static"))
o:value("none", translate("Disabled"))
o.default = wan.proto

o = s:option(Value, "ipv4_addr", translate("IP address"))
o:depends("ipv4", "static")
o.value = wan.ipaddr
o.datatype = "ip4addr"
o.rmempty = false

o = s:option(Value, "ipv4_netmask", translate("Netmask"))
o:depends("ipv4", "static")
o.value = wan.netmask or "255.255.255.0"
o.datatype = "ip4addr"
o.rmempty = false

o = s:option(Value, "ipv4_gateway", translate("Gateway"))
o:depends("ipv4", "static")
o.value = wan.gateway
o.datatype = "ip4addr"
o.rmempty = false


s = f:section(SimpleSection, nil, nil)

o = s:option(ListValue, "ipv6", translate("IPv6"))
o:value("dhcpv6", translate("Automatic (RA/DHCPv6)"))
o:value("static", translate("Static"))
o:value("none", translate("Disabled"))
o.default = wan6.proto

o = s:option(Value, "ipv6_addr", translate("IP address"))
o:depends("ipv6", "static")
o.value = wan6.ip6addr
o.datatype = "ip6addr"
o.rmempty = false

o = s:option(Value, "ipv6_gateway", translate("Gateway"))
o:depends("ipv6", "static")
o.value = wan6.ip6gw
o.datatype = "ip6addr"
o.rmempty = false


if dns then
  s = f:section(SimpleSection, nil, nil)

  o = s:option(DynamicList, "dns", translate("Static DNS servers"))
  o:write(nil, uci:get("gluon-wan-dnsmasq", dns, "server"))
  o.datatype = "ipaddr"
end

s = f:section(SimpleSection, nil, nil)

o = s:option(Flag, "mesh_wan", translate("Enable meshing on the WAN interface"))
o.default = uci:get_bool("network", "mesh_wan", "auto") and o.enabled or o.disabled
o.rmempty = false

if sysconfig.lan_ifname then
  o = s:option(Flag, "mesh_lan", translate("Enable meshing on the LAN interface"))
  o.default = uci:get_bool("network", "mesh_lan", "auto") and o.enabled or o.disabled
  o.rmempty = false
end


function f.handle(self, state, data)
  if state == FORM_VALID then
    uci:set("network", "wan", "proto", data.ipv4)
    if data.ipv4 == "static" then
      uci:set("network", "wan", "ipaddr", data.ipv4_addr)
      uci:set("network", "wan", "netmask", data.ipv4_netmask)
      uci:set("network", "wan", "gateway", data.ipv4_gateway)
    else
      uci:delete("network", "wan", "ipaddr")
      uci:delete("network", "wan", "netmask")
      uci:delete("network", "wan", "gateway")
    end

    uci:set("network", "wan6", "proto", data.ipv6)
    if data.ipv6 == "static" then
      uci:set("network", "wan6", "ip6addr", data.ipv6_addr)
      uci:set("network", "wan6", "ip6gw", data.ipv6_gateway)
    else
      uci:delete("network", "wan6", "ip6addr")
      uci:delete("network", "wan6", "ip6gw")
    end

    uci:set("network", "mesh_wan", "auto", data.mesh_wan)

    if sysconfig.lan_ifname then
      uci:set("network", "mesh_lan", "auto", data.mesh_lan)

      if data.mesh_lan == '1' then
        uci:set("network", "client", "ifname", "bat0")
      else
        uci:set("network", "client", "ifname", sysconfig.lan_ifname .. " bat0")
      end
    end

    uci:save("network")
    uci:commit("network")

    if dns then
      if #data.dns > 0 then
        uci:set("gluon-wan-dnsmasq", dns, "server", data.dns)
      else
        uci:delete("gluon-wan-dnsmasq", dns, "server")
      end

      uci:save("gluon-wan-dnsmasq")
      uci:commit("gluon-wan-dnsmasq")
    end
  end

  return true
end

return f
