--[[
Copyright 2022 Maciej Krüger <maciej@xeredo.it>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0
]]--

package 'gluon-web-mesh-vpn-openvpn'

local file
local tmpfile = "/tmp/vpninput"

local vpn_core = require 'gluon.mesh-vpn'
local unistd = require 'posix.unistd'

local function filehandler(_, chunk, eof)
	if not unistd.access(tmpfile) and not file and chunk and #chunk > 0 then
		file = io.open(tmpfile, "w")
	end
	if file and chunk then
		file:write(chunk)
	end
	if file and eof then
		file:close()
	end
end

if vpn_core.enabled() then
	local vpn = entry({"admin", "mesh_vpn_openvpn"}, model("admin/mesh_vpn_openvpn"), _("Mesh VPN"), 50)
	vpn.filehandler = filehandler
end
