return function(form, uci)
	local platform = require 'gluon.platform'

	if not platform.is_outdoor_device() then
		-- only visible on wizard for outdoor devices
		return
	end

	local pkg_i18n = i18n 'gluon-config-mode-outdoor'

	local section = form:section(Section, nil, pkg_i18n.translate(
		"Please enable this option in case the node is to be installed outdoors "
		.. "to comply with local frequency regulations."
	))

	local outdoor = section:option(Flag, 'outdoor', pkg_i18n.translate("Node will be installed outdoors"))
	outdoor.default = uci:get_bool('gluon', 'wireless', 'outdoor')

	function outdoor:write(data)
		if data ~= outdoor_mode then
			uci:set('gluon', 'wireless', 'outdoor', data)
			uci:save('gluon')
			os.execute('/lib/gluon/upgrade/200-wireless')
		end
	end

	return {'gluon', 'wireless'}
end
