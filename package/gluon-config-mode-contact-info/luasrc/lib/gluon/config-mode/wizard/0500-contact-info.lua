return function(form, uci)
	local site = require 'gluon.site'

	local owner = uci:get_first("gluon-node-info", "owner")

	local s = form:section(Section, nil, translate(
		'Please provide your contact information here to '
		.. 'allow others to contact you. Note that '
		.. 'this information will be visible <em>publicly</em> '
		.. 'on the internet together with your node\'s coordinates.'
	))

	local contact_field = s:option(Value, "contact", translate("Contact info"), translate("e.g. E-mail or phone number"))
	contact_field.default = uci:get("gluon-node-info", owner, "contact")
	contact_field.optional = not ((site.config_mode or {}).owner or {}).obligatory
	-- without a minimal length, an empty string will be accepted even with "optional = false"
	contact_field.datatype='minlength(1)'
	contact_field.maxlen = 140

	local no_name = s:option(Flag, "no_name", translate("Anonymous node"))
	no_name.default = false

	contact_field:depends(no_name, false)

	-- TODO: this should only be shown, if no_name is true
	local s = form:section(Section, nil, translate(
		"We respect your wish to operate the node anonymously. In order to operate a "
		.. "Freifunk network, it is necessary that we can reach the operators of the "
		.. "nodes. So please let us know an alternative way how we could contact you in "
		.. "case there is anything wrong with your node."
		)
	)
	-- TODO: this doesn't work:
	-- s:depends(no_name, false)

	function contact_field:write(data)
		if data then
			uci:set("gluon-node-info", owner, "contact", data)
		else
			uci:delete("gluon-node-info", owner, "contact")
		end
	end

	return {'gluon-node-info'}
end
