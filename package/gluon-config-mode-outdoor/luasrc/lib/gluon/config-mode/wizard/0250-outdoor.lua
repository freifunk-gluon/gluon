return function(form, uci)
	local platform = require 'gluon.platform'
	local wireless = require 'gluon.wireless'

	if not (platform.is_outdoor_device() and platform.device_uses_11a(uci)) then
		-- only visible on wizard for outdoor devices
		return
	end

	if wireless.preserve_channels(uci) then
		-- Don't show if channel should be preserved
		return
	end

	local pkg_i18n = i18n 'gluon-config-mode-outdoor'

	local section = form:section(Section, nil, pkg_i18n.translate(
		"Please enable this option in case the node is to be installed outdoors "
		.. "to comply with local frequency regulations."
	))

	local outdoor_mode = uci:get_bool('gluon', 'wireless', 'outdoor')
	local outdoor = section:option(Flag, 'outdoor', pkg_i18n.translate("Node will be installed outdoors"))
	outdoor.default = outdoor_mode

	function outdoor:write(data)
		if data ~= outdoor_mode then
			uci:set('gluon', 'wireless', 'outdoor', data)
			uci:save('gluon')

			if data == false then
				local mesh_ifaces_5ghz = {}
				uci:foreach('wireless', 'wifi-device', function(config)
					if config.band ~= '5g' then
						return
					end

					local radio_name = config['.name']
					local mesh_iface = 'mesh_' .. radio_name
					table.insert(mesh_ifaces_5ghz, mesh_iface)
				end)
				for _, mesh_iface in ipairs(mesh_ifaces_5ghz) do
					uci:delete('wireless', mesh_iface)
				end
				uci:save('wireless')
			end
		end
	end
end
