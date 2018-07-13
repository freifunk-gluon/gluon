local unistd = require 'posix.unistd'

local has_fastd = unistd.access('/lib/gluon/mesh-vpn/fastd')
local has_tunneldigger = unistd.access('/lib/gluon/mesh-vpn/tunneldigger')

return function(form, uci)
	if not (has_fastd or has_tunneldigger) then
		return
	end

	local pkg_i18n = i18n 'gluon-config-mode-mesh-vpn'

	local msg = pkg_i18n.translate(
		'Your internet connection can be used to establish a ' ..
	        'VPN connection with other nodes. ' ..
	        'Enable this option if there are no other nodes reachable ' ..
	        'over WLAN in your vicinity or you want to make a part of ' ..
	        'your connection\'s bandwidth available for the network. You can limit how ' ..
	        'much bandwidth the node will use at most.'
	)

	local s = form:section(Section, nil, msg)

	local o

	local meshvpn = s:option(Flag, "meshvpn", pkg_i18n.translate("Use internet connection (mesh VPN)"))
	meshvpn.default = uci:get_bool("fastd", "mesh_vpn", "enabled") or uci:get_bool("tunneldigger", "mesh_vpn", "enabled")
	function meshvpn:write(data)
		if has_fastd then
			uci:set("fastd", "mesh_vpn", "enabled", data)
		end
		if has_tunneldigger then
			uci:set("tunneldigger", "mesh_vpn", "enabled", data)
		end
	end

	local limit = s:option(Flag, "limit_enabled", pkg_i18n.translate("Limit bandwidth"))
	limit:depends(meshvpn, true)
	limit.default = uci:get_bool("simple-tc", "mesh_vpn", "enabled")
	function limit:write(data)
		uci:set("simple-tc", "mesh_vpn", "interface")
		uci:set("simple-tc", "mesh_vpn", "enabled", data)
		uci:set("simple-tc", "mesh_vpn", "ifname", "mesh-vpn")
	end

	o = s:option(Value, "limit_ingress", pkg_i18n.translate("Downstream (kbit/s)"))
	o:depends(limit, true)
	o.default = uci:get("simple-tc", "mesh_vpn", "limit_ingress")
	o.datatype = "uinteger"
	function o:write(data)
		uci:set("simple-tc", "mesh_vpn", "limit_ingress", data)
	end

	o = s:option(Value, "limit_egress", pkg_i18n.translate("Upstream (kbit/s)"))
	o:depends(limit, true)
	o.default = uci:get("simple-tc", "mesh_vpn", "limit_egress")
	o.datatype = "uinteger"
	function o:write(data)
		uci:set("simple-tc", "mesh_vpn", "limit_egress", data)
	end

	return {'fastd', 'tunneldigger', 'simple-tc'}
end
