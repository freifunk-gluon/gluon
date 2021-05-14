return function(form, uci)
	local pkg_i18n = i18n 'gluon-config-mode-contact-info'
	local site_i18n = i18n 'gluon-site'

	local owner = uci:get_first("gluon-node-info", "owner")

	local help = site_i18n._translate("gluon-config-mode:contact-help") or pkg_i18n.translate(
		'Please provide your contact information here to allow others to contact '
		.. 'you. Note that this information will be visible <em>publicly</em> on '
		.. 'the internet together with your node\'s coordinates. This means it can '
		.. 'be downloaded and processed by anyone. This information is '
		.. 'not required to operate a node. If you chose to enter data, it will be '
		.. 'stored on this node and can be deleted by yourself at any time.'
	)
	local s = form:section(Section, nil, help)

	local o = s:option(Value, "contact", pkg_i18n.translate("Contact info"),
		site_i18n._translate("gluon-config-mode:contact-note") or pkg_i18n.translate("e.g. E-mail or phone number"))
	o.default = uci:get("gluon-node-info", owner, "contact")
	o.datatype = 'minlength(1)'
	o.optional = true
	function o:write(data)
		uci:set("gluon-node-info", owner, "contact", data)
		uci:save("gluon-node-info")
	end
end
