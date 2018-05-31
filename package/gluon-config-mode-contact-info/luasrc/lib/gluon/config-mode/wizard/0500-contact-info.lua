return function(form, uci)
	local pkg_i18n = i18n 'gluon-config-mode-contact-info'

	local site = require 'gluon.site'

	local owner = uci:get_first("gluon-node-info", "owner")

	local s = form:section(Section, nil, translate("gluon-config-mode:contact-help"))

	local o = s:option(Value, "contact", pkg_i18n.translate("Contact info"), pkg_i18n.translate("e.g. E-mail or phone number"))
	o.default = uci:get("gluon-node-info", owner, "contact")
	o.optional = true
	function o:write(data)
		uci:set("gluon-node-info", owner, "contact", data)
	end

	return {'gluon-node-info'}
end
