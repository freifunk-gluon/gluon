local uci = require('simple-uci').cursor()

local pkg_i18n = i18n 'gluon-web-offline-ssid'

local f = Form(pkg_i18n.translate('Offline-SSID'))

local s = f:section(Section, nil, pkg_i18n.translate(
	'Here you can control the automatic change of the SSID to the Offline-SSID '
	.. 'when the node has no connection to the selected gateway.'
))

local disabled = s:option(Flag, 'disabled', pkg_i18n.translate('Disabled'))
disabled.default = uci:get_bool('gluon-offline-ssid', 'settings', 'disabled')

function f:write()
	if disabled.data then
		uci:set('gluon-offline-ssid', 'settings', 'disabled', '1')
	else
		uci:set('gluon-offline-ssid', 'settings', 'disabled', '0')
	end

	uci:commit('gluon-offline-ssid')
end

return f
