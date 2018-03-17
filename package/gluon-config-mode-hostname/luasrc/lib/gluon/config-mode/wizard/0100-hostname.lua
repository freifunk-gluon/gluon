return function(form, uci)
	local pkg_i18n = i18n 'gluon-config-mode-hostname'

	local pretty_hostname = require "pretty_hostname"

	form:section(Section, nil, pkg_i18n.translate(
		"The node name is used solely for identification of your node, e.g. on a "
		.. "node map. It does not affect the name (SSID) of the broadcasted WLAN."
	))

	local s = form:section(Section)
	local o = s:option(Value, "hostname", pkg_i18n.translate("Node name"))
	o.default = pretty_hostname.get(uci)

	function o:write(data)
		pretty_hostname.set(uci, data)
	end

	return {'system'}
end
