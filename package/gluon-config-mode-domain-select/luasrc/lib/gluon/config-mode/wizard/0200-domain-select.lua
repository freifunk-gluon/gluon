
return function(form, uci)
	local site_i18n = i18n 'gluon-site'

	local json = require 'jsonc'
	local site = require 'gluon.site'
	local util = require 'gluon.util'

	local selected_domain = uci:get('gluon', 'core', 'domain')
	local configured = uci:get_first('gluon-setup-mode','setup_mode', 'configured') == '1' or (selected_domain ~= site.default_domain())

	local function hide_domain_code(domain, code)
		if configured and code == selected_domain then
			return false
		elseif type(domain.hide_domain) == 'table' then
			return util.contains(domain.hide_domain, code)
		else
			return domain.hide_domain
		end
	end

	local function get_domain_list()
		local list = {}
		for _, domain_path in ipairs(util.glob('/lib/gluon/domains/*.json')) do
			local domain_code = domain_path:match('([^/]+)%.json$')
			local domain = assert(json.load(domain_path))

			if not hide_domain_code(domain, domain_code) then
				table.insert(list, {
					domain_code = domain_code,
					domain_name = domain.domain_names[domain_code],
				})
			end
		end

		table.sort(list, function(a, b) return a.domain_name < b.domain_name end)
		return list
	end

	local s = form:section(Section, nil, site_i18n.translate('gluon-config-mode:domain-select'))
	local o = s:option(ListValue, 'domain', site_i18n.translate('gluon-config-mode:domain'))

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
