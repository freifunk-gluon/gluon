--[[
Copyright 2014 Nils Schneider <nils@nilsschneider.net>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0
]]--

local uci = require("simple-uci").cursor()

local wan = uci:get_all("network", "wan")
local wan6 = uci:get_all("network", "wan6")
local dns_static = uci:get_first("gluon-wan-dnsmasq", "static")


local f = Form(translate("WAN connection"))

local s = f:section(Section)

local ipv4 = s:option(ListValue, "ipv4", translate("IPv4"))
ipv4:value("dhcp", translate("Automatic (DHCP)"))
ipv4:value("static", translate("Static"))
ipv4:value("none", translate("Disabled"))
ipv4.default = wan.proto

local ipv4_addr = s:option(Value, "ipv4_addr", translate("IP address"))
ipv4_addr:depends(ipv4, "static")
ipv4_addr.default = wan.ipaddr
ipv4_addr.datatype = "ip4addr"

local ipv4_netmask = s:option(Value, "ipv4_netmask", translate("Netmask"))
ipv4_netmask:depends(ipv4, "static")
ipv4_netmask.default = wan.netmask or "255.255.255.0"
ipv4_netmask.datatype = "ip4addr"

local ipv4_gateway = s:option(Value, "ipv4_gateway", translate("Gateway"))
ipv4_gateway:depends(ipv4, "static")
ipv4_gateway.default = wan.gateway
ipv4_gateway.datatype = "ip4addr"


s = f:section(Section)

local ipv6 = s:option(ListValue, "ipv6", translate("IPv6"))
ipv6:value("dhcpv6", translate("Automatic (RA/DHCPv6)"))
ipv6:value("static", translate("Static"))
ipv6:value("none", translate("Disabled"))
ipv6.default = wan6.proto

local ipv6_addr = s:option(Value, "ipv6_addr", translate("IP address"))
ipv6_addr:depends(ipv6, "static")
ipv6_addr.default = wan6.ip6addr
ipv6_addr.datatype = "ip6addr"

local ipv6_gateway = s:option(Value, "ipv6_gateway", translate("Gateway"))
ipv6_gateway:depends(ipv6, "static")
ipv6_gateway.default = wan6.ip6gw
ipv6_gateway.datatype = "ip6addr"

if dns_static then
	s = f:section(Section)

	local dns = s:option(DynamicList, "dns", translate("Static DNS servers"))
	dns.default = uci:get_list("gluon-wan-dnsmasq", dns_static, "server")
	dns.datatype = "ipaddr"
	dns.optional = true

	function dns:write(data)
		uci:set_list("gluon-wan-dnsmasq", dns_static, "server", data)
		uci:commit("gluon-wan-dnsmasq")
	end
end

s = f:section(Section)

local pretty_ifnames = {
	["/wan"] = translate("WAN Interfaces"),
	["/single"] = translate("Interface"),
	["/lan"] = translate("LAN Interfaces")
}

uci:foreach('gluon', 'interface', function(config)
	local section_name = config['.name']
	local ifaces = s:option(MultiListValue, section_name, pretty_ifnames[config.name] or config.name)

	ifaces.orientation = 'horizontal'
	ifaces:value('uplink', 'Uplink')
	ifaces:value('mesh', 'Mesh')
	ifaces:value('client', 'Client')

	ifaces.default = config.role

	function ifaces:write(data)
		uci:set_list("gluon", section_name, "role", data)
	end
end)


local section
uci:foreach("system", "gpio_switch", function(si)
	if si[".name"]:match("poe") then
		if not section then
			section = f:section(Section)
		end

		local texts = {
			["^PoE Power Port(%d*)$"] = function(m) return translatef("Enable PoE Power Port %s", m[1]) end,
			["^PoE Passthrough$"] = function() return translate("Enable PoE Passthrough") end,
		}

		local name
		for pattern, func in pairs(texts) do
			local match = {si.name:match(pattern)}
			if match[1] then
				name = func(match)
				break
			end
		end
		if not name then
			name = translatef('Enable "%s"', si.name)
		end

		local poe = section:option(Flag, si[".name"], name)
		poe.default = uci:get_bool("system", si[".name"], "value")

		function poe:write(data)
			uci:set("system", si[".name"], "value", data)
		end
	end
end)

function f:write()
	uci:set("network", "wan", "proto", ipv4.data)
	if ipv4.data == "static" then
		uci:set("network", "wan", "ipaddr", ipv4_addr.data)
		uci:set("network", "wan", "netmask", ipv4_netmask.data)
		uci:set("network", "wan", "gateway", ipv4_gateway.data)
	else
		uci:delete("network", "wan", "ipaddr")
		uci:delete("network", "wan", "netmask")
		uci:delete("network", "wan", "gateway")
	end

	uci:set("network", "wan6", "proto", ipv6.data)
	if ipv6.data == "static" then
		uci:set("network", "wan6", "ip6addr", ipv6_addr.data)
		uci:set("network", "wan6", "ip6gw", ipv6_gateway.data)
	else
		uci:delete("network", "wan6", "ip6addr")
		uci:delete("network", "wan6", "ip6gw")
	end

	uci:commit('gluon')
	uci:commit("network")
	uci:commit('system')
end


return f
