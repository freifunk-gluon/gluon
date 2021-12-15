return function(form, uci)
	if active_vpn == nil then
		return
	end

	local pkg_i18n = i18n 'gluon-config-mode-manman-sync'

	local msg = pkg_i18n.translate(
		'Sync data from ManMan ' ..
		'by entering ManMan location id here.\n' ..
		'This will automatically keep name, location and ips ' ..
			'in sync with the values specified in ManMan.'
	)

	local s = form:section(Section, nil, msg)

	local o

	local manman = s:option(Flag, "manman_sync", pkg_i18n.translate("Enable ManMan sync"))
	manman.default = uci:get_bool("gluon", "manman_sync", "enabled")
	function manman:write(data)
		uci:set("gluon", "manman_sync", "enabled", data)
	end

	local id = s:option(Value, "manman_id", pkg_i18n.translate("ManMan location ID"))
	id:depends(manman, true)
	id.default = uci:get("gluon", "manman_sync", "node_id")
	id.datatype = "nfloat" -- TODO: int
	function id:write(data)
		uci:set("gluon", "manman_sync", "node_id", data)
	end

	function s:write()
		uci:save('gluon')
	end
end
