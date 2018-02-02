return function(form, uci)
	local fs = require 'nixio.fs'
	local json = require 'jsonc'
	local site = require 'gluon.site'

	local selected_domain = uci:get('gluon', 'core', 'domain')
	local configured = uci:get_first('gluon-setup-mode','setup_mode', 'configured') == '1' or (selected_domain ~= site.default_domain())

	local function get_domain_list()
		local list = {}
		for domain_path in fs.glob('/lib/gluon/domains/*.json') do
			local domain_code = domain_path:match('([^/]+)%.json$')
			local domain = assert(json.load(domain_path))

			if not domain.hide_domain or (configured and domain.domain_code == selected_domain) then
				table.insert(list, {
					domain_code = domain_code,
					domain_name = domain.domain_names[domain_code],
				})
			end
		end

		table.sort(list, function(a, b) return a.domain_name < b.domain_name end)
		return list
	end

	local s = form:section(Section, nil, translate('gluon-config-mode:domain-select'))
	local o = s:option(ListValue, 'domain', translate('gluon-config-mode:domain'))

	if configured then
		o.default = selected_domain
	end

	for _, domain in ipairs(get_domain_list()) do
		o:value(domain.domain_code, domain.domain_name)
	end

	local domain_changed = false

	function o:write(data)
		if data ~= selected_domain then
			domain_changed = true
			uci:set('gluon', 'core', 'domain', data)
		end
	end

	local function reconfigure()
		if domain_changed then
			os.execute('gluon-reconfigure')
		end
	end

	return {'gluon', reconfigure}
end
