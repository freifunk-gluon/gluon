return function(form, uci)
	local site = require 'gluon.site'
	local path = '/lib/gluon/domains'
	local fs = require 'nixio.fs'
	local json = require 'jsonc'

	local function get_domain_list()
		local list = {}
		for domain_path in fs.glob(path .. '/*.json') do
			local domain_code = domain_path:match(path .. '/(.*)%.json$')
			local domain = assert(json.load(domain_path))
			table.insert(list, {
				domain_code = domain_code,
				domain_name = (domain.domain_names or {})[domain_code],
				hide_domain = domain.hide_domain or False,
			})
		end
		table.sort(list, function(a,b) return a.domain_name < b.domain_name end)
		return list
	end

	local s = form:section(Section, nil, translate('gluon-config-mode:domain-select'))
	local o = s:option(ListValue, 'domain', translate('gluon-config-mode:domain'))

	if uci:get_bool('gluon-setup-mode', uci:get_first('gluon-setup-mode','setup_mode'), 'configured')  then
		o.default = uci:get('gluon', 'core', 'domain')
	end

	for _, domain in pairs(get_domain_list()) do
		if not domain.hide_domain then
			o:value(domain.domain_code, domain.domain_name)
		end
	end

	function o:write(data)
		uci:set('gluon', 'core', 'domain', data)
		uci:save('gluon')
		os.execute('gluon-reconfigure')
	end

	return {'gluon'}
end
