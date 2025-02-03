local json = require 'jsonc'
local Validator = require 'gluon.validator'

local function config_error(src, ...)
	error(src .. ' error: ' .. string.format(...), 0)
end

local has_domains = (os.execute('ls -d "$IPKG_INSTROOT"/lib/gluon/domains/ >/dev/null 2>&1') == 0)


local function get_domains()
	local domains = {}
	local dirs = io.popen("find \"$IPKG_INSTROOT\"/lib/gluon/domains/ -name '*.json'")
	for filename in dirs:lines() do
		local name = string.match(filename, '([^/]+).json$')
		domains[name] = assert(json.load(filename))
	end
	dirs:close()

	if not next(domains) then
		config_error('site', 'no domain configurations found')
	end

	return domains
end

local site, domain_code, domain, conf


local M = {}

local function merge(a, b)
	local function is_array(t)
		local n = 0
		for _ in pairs(t) do
			n = n + 1
		end
		return n == #t
	end

	if not b then return a end
	if type(a) ~= type(b) then return b end
	if type(b) ~= 'table' then return b end
	if not next(b) then return a end
	if is_array(a) ~= is_array(b) then return b end

	local m = {}
	for k, v in pairs(a) do
		m[k] = v
	end
	for k, v in pairs(b) do
		m[k] = merge(m[k], v)
	end

	return m
end

local function path_to_string(path)
	if path.is_value then
		return path.label
	end

	return table.concat(path, '.')
end

function M.table_keys(tbl)
	local keys = {}
	for k in pairs(tbl) do
		keys[#keys + 1] = k
	end
	return keys
end

local ConfValidator = {}
setmetatable(ConfValidator, { __index = Validator })

local function site_src()
	return 'site.conf'
end

local function domain_src()
	return 'domains/' .. domain_code .. '.conf'
end

function ConfValidator:conf_src(path)
	if path.is_value then
		return 'Configuration'
	end

	local src

	if has_domains then
		if self:loadpath(nil, domain, unpack(path)) ~= nil then
			src = domain_src()
		elseif self:loadpath(nil, site, unpack(path)) ~= nil then
			src = site_src()
		else
			src = site_src() .. ' / ' .. domain_src()
		end
	else
		src = site_src()
	end

	return src
end

function ConfValidator:var_error(path, val, msg)
	local found = 'unset'
	if val ~= nil then
		found = string.format('%s (a %s value)', Validator.format(val), type(val))
	end

	config_error(self:conf_src(path), 'expected %s to %s, but it is %s', path_to_string(path), msg, found)
end

function ConfValidator:in_site(path)
	if has_domains and self:loadpath(nil, domain, unpack(path)) ~= nil then
		config_error(domain_src(), '%s is allowed in site configuration only', path_to_string(path))
	end

	return path
end

function ConfValidator:in_domain(path)
	if has_domains and self:loadpath(nil, site, unpack(path)) ~= nil then
		config_error(site_src(), '%s is allowed in domain configuration only', path_to_string(path))
	end

	return path
end

function M.value(label, value)
	return {
		is_value = true,
		label = label,
		value = value,
	}
end

function M.this_domain()
	return domain_code
end

function M.alternatives(...)
	local errs = {'All of the following alternatives have failed:'}
	for i, f in ipairs({...}) do
		local ok, err = pcall(f)
		if ok then
			return
		end
		errs[#errs+1] = string.format('%i) %s', i, err)
	end

	error(table.concat(errs, '\n        '), 0)
end

function ConfValidator:obsolete(path, msg)
	local val = self:loadvar(path)
	if val == nil then
		return nil
	end

	if not msg then
		msg = 'Check the release notes and documentation for details.'
	end

	config_error(self:conf_src(path), '%s is obsolete. %s', path_to_string(path), msg)
end

local function method_call_wrapper(obj, method_name)
	return function (...)
		return obj[method_name](obj, ...)
	end
end

local check_site_file_content = assert(loadfile())

local function check(conf_validator)
	local scope = {}
	setmetatable(scope, { __index = function(_, k)
		if M[k] then
			-- Functions defined in this module.
			return M[k]
		elseif conf_validator[k] then
			-- need_*() methods from the conf_validator.
			--
			-- We need method_call_wrapper() since conf_validator is a "class"
			-- and class methods expect "self" as first argument, but the
			-- need_*() calls in check_site.lua doesn't pass a self argument.
			return method_call_wrapper(conf_validator, k)
		elseif _G[k] then
			-- This is necessary for globals like ipairs(), pairs(), etc. to
			-- be available within check_site.lua scripts.
			return _G[k]
		end
	end })
	return setfenv(check_site_file_content, scope)()
end

site = assert(json.load((os.getenv('IPKG_INSTROOT') or '') .. '/lib/gluon/site.json'))

local ok, err = pcall(function()
	if has_domains then
		for k, v in pairs(get_domains()) do
			domain_code = k
			domain = v
			conf = merge(site, domain)
			local conf_validator = ConfValidator:new(conf)
			check(conf_validator)
		end
	else
		conf = site
		local conf_validator = ConfValidator:new(conf)
		check(conf_validator)
	end
end)

if not ok then
	io.stderr:write('*** ', err, '\n')
	os.exit(1)
end
