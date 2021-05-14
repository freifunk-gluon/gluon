return function(form, uci)
	local pkg_i18n = i18n 'gluon-config-mode-hostname'
	local site_i18n = i18n 'gluon-site'

	local pretty_hostname = require 'pretty_hostname'
	local site = require 'gluon.site'
	local util = require 'gluon.util'

	local help = site_i18n._translate("gluon-config-mode:hostname-help") or pkg_i18n.translate(
		'The node name is used solely for identification of your node, e.g. on a '
		.. 'node map. It does not affect the name (SSID) of the broadcasted WLAN.'
	)
	form:section(Section, nil, help)

	local current_hostname = pretty_hostname.get(uci)
	local default_hostname = util.default_hostname()
	local configured = uci:get_first('gluon-setup-mode', 'setup_mode', 'configured', false) or
		(current_hostname ~= default_hostname)

	local s = form:section(Section)
	local o = s:option(Value, "hostname", pkg_i18n.translate("Node name"))
	o.datatype = 'minlength(1)'
	if site.config_mode.hostname.optional(true) then
		o.optional = true
		o.placeholder = default_hostname
	end
	if configured or site.config_mode.hostname.prefill(true) then
		o.default = current_hostname
	end

	function o:write(data)
		pretty_hostname.set(uci, data or default_hostname)
		uci:save('system')
	end
end
