return function(form, uci)
	local pkg_i18n = i18n 'gluon-config-mode-manman-sync'

	local msg = pkg_i18n.translate(
		'Sync configuration from ManMan ' ..
			'by entering ManMan location id here.\n' ..
		'This will automatically keep name, location and ips ' ..
			'in sync with the values specified in ManMan.'
	)

	local s = form:section(Section, nil, msg)

	local o

	local manman = s:option(Flag, 'manman_sync', pkg_i18n.translate('Enable ManMan sync'))
	manman.default = uci:get_bool('gluon-manman-sync', 'sync', 'enabled')
	function manman:write(data)
		uci:set('gluon-manman-sync', 'sync', 'enabled', data)
	end

	local id = s:option(Value, 'manman_id', pkg_i18n.translate('ManMan location ID'))
	id:depends(manman, true)
	id.default = uci:get('gluon-manman-sync', 'sync', 'location_id')
	id.datatype = 'uinteger'
	function id:write(data)
		uci:set('gluon-manman-sync', 'sync', 'location_id', data)
	end

	local id = s:option(Value, 'manman_node', pkg_i18n.translate('ManMan node (optional)'))
	id:depends(manman, true)
	id.default = uci:get('gluon-manman-sync', 'sync', 'node')
	id.datatype = 'maxlength(16)'
	function id:write(data)
		uci:set('gluon-manman-sync', 'sync', 'node', data)
	end

	function s:write()
		uci:save('gluon-manman-sync')
	end
end
