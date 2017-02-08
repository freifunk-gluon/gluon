return function(form, uci)
	local pretty_hostname = require "pretty_hostname"

	local s = form:section(Section)
	local o = s:option(Value, "hostname", translate("Node name"))
	o.default = pretty_hostname.get(uci)

	function o:write(data)
		pretty_hostname.set(uci, data)
	end

	return {'system'}
end
