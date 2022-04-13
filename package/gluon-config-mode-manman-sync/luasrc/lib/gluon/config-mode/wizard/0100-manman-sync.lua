return function(form, uci)
	local pkg_i18n = i18n 'gluon-config-mode-manman-sync'

	local msg = pkg_i18n.translate(
		'Sync configuration from ManMan ' ..
			'by entering ManMan location and node name here.<br>' ..
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

	local id = s:option(Value, 'manman_location', pkg_i18n.translate('ManMan location'))
	id:depends(manman, true)
	id.default = uci:get('gluon-manman-sync', 'sync', 'location')
	id.datatype = 'maxlength(16)'
	function id:write(data)
		-- clear ID, gets fetched from manman-sync
		uci:set('gluon-manman-sync', 'sync', 'location_id', nil)

		uci:set('gluon-manman-sync', 'sync', 'location', data)
	end

	local id = s:option(Value, 'manman_node', pkg_i18n.translate('ManMan node (optional)'), pkg_i18n.translate('Required if multiple nodes in location'))
	id:depends(manman, true)
	id.default = uci:get('gluon-manman-sync', 'sync', 'node')
	id.datatype = 'maxlength(16)'
	function id:write(data)
		-- clear ID, gets fetched from manman-sync
		uci:set('gluon-manman-sync', 'sync', 'node_id', nil)

		uci:set('gluon-manman-sync', 'sync', 'node', data)
	end

	function s:write()
		uci:save('gluon-manman-sync')
	end
end
