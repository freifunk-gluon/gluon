return function(form, uci)
	local pkg_i18n = i18n 'gluon-config-mode-contact-info'
	local site_i18n = i18n 'gluon-site'

	local site = require 'gluon.site'

	local owner = uci:get_first("gluon-node-info", "owner")

	local s = form:section(Section, nil, site_i18n.translate("gluon-config-mode:contact-help"))

	local o = s:option(Value, "contact", pkg_i18n.translate("Contact info"),
		site_i18n._translate("gluon-config-mode:contact-note") or pkg_i18n.translate("e.g. E-mail or phone number"))
	o.default = uci:get("gluon-node-info", owner, "contact")
	o.optional = true
	function o:write(data)
		uci:set("gluon-node-info", owner, "contact", data)
	end

	return {'gluon-node-info'}
end
