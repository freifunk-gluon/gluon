local cjson = require 'cjson'

local function config_error(src, ...)
	error(src .. ' error: ' .. string.format(...), 0)
end

local has_domains = (os.execute('ls -d "$IPKG_INSTROOT"/lib/gluon/domains/ >/dev/null 2>&1') == 0)


local function load_json(filename)
	local f = assert(io.open(filename))
	local json = cjson.decode(f:read('*a'))
	f:close()
	return json
end


local function get_domains()
	local domains = {}
	local dirs = io.popen("find \"$IPKG_INSTROOT\"/lib/gluon/domains/ -name '*.json'")
	for filename in dirs:lines() do
		local name = string.match(filename, '([^/]+).json$')
		domains[name] = load_json(filename)
	end
	dirs:close()

	if not next(domains) then
		config_error('site', 'no domain configurations found')
	end

	return domains
end

local site, domain_code, domain, conf


local function merge(a, b)
	local function is_array(t)
		local n = 0
		for k, v in pairs(t) do
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
	return table.concat(path, '.')
end

local function array_to_string(array)
	return '[' .. table.concat(array, ', ') .. ']'
end

function table_keys(tbl)
	local keys = {}
	for k, _ in pairs(tbl) do
		keys[#keys + 1] = k
	end
	return keys
end


local loadpath

local function site_src()
	return 'site.conf'
end

local function domain_src()
	return 'domains/' .. domain_code .. '.conf'
end

local function conf_src(path)
	local src

	if has_domains then
		if loadpath(nil, domain, unpack(path)) ~= nil then
			src = domain_src()
		elseif loadpath(nil, site, unpack(path)) ~= nil then
			src = site_src()
		else
			src = site_src() .. ' / ' .. domain_src()
		end
	else
		src = site_src()
	end

	return src
end

local function var_error(path, val, msg)
	if type(val) == 'string' then
		val = string.format('%q', val)
	end

	local found = 'unset'
	if val ~= nil then
		found = string.format('%s (a %s value)', tostring(val), type(val))
	end

	config_error(conf_src(path), 'expected %s to %s, but it is %s', path_to_string(path), msg, found)
end

function in_site(path)
	if has_domains and loadpath(nil, domain, unpack(path)) ~= nil then
		config_error(domain_src(), '%s is allowed in site configuration only', path_to_string(path))
	end

	return path
end

function in_domain(path)
	if has_domains and loadpath(nil, site, unpack(path)) ~= nil then
		config_error(site_src(), '%s is allowed in domain configuration only', path_to_string(path))
	end

	return path
end

function this_domain()
	return domain_code
end


function extend(path, c)
	if not path then return nil end

	local p = {unpack(path)}

	for _, e in ipairs(c) do
		p[#p+1] = e
	end
	return p
end

function loadpath(path, base, c, ...)
	if not c or base == nil then
		return base
	end

	if type(base) ~= 'table' then
		if path then
			var_error(path, base, 'be a table')
		else
			return nil
		end
	end

	return loadpath(extend(path, {c}), base[c], ...)
end

local function loadvar(path)
	return loadpath({}, conf, unpack(path))
end

local function check_type(t)
	return function(val)
		return type(val) == t
	end
end

local function check_one_of(array)
	return function(val)
		for _, v in ipairs(array) do
			if v == val then
				return true
			end
		end
		return false
	end
end


function alternatives(...)
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


function need(path, check, required, msg)
	local val = loadvar(path)
	if required == false and val == nil then
		return nil
	end

	if not check(val) then
		var_error(path, val, msg)
	end

	return val
end

local function need_type(path, type, required, msg)
	return need(path, check_type(type), required, msg)
end


function need_alphanumeric_key(path)
	local val = path[#path]
	-- We don't use character classes like %w here to be independent of the locale
	if type(val) ~= 'string' or not val:match('^[0-9a-zA-Z_]+$') then
		var_error(path, val, 'have a string key using only alphanumeric characters and underscores')
	end
end


function need_string(path, required)
	return need_type(path, 'string', required, 'be a string')
end

function need_string_match(path, pat, required)
	local val = need_string(path, required)
	if not val then
		return nil
	end

	if not val:match(pat) then
		var_error(path, val, "match pattern '" .. pat .. "'")
	end

	return val
end

function need_number(path, required)
	return need_type(path, 'number', required, 'be a number')
end

function need_boolean(path, required)
	return need_type(path, 'boolean', required, 'be a boolean')
end

function need_array(path, subcheck, required)
	local val = need_type(path, 'table', required, 'be an array')
	if not val then
		return nil
	end

	if subcheck then
		for i = 1, #val do
			subcheck(extend(path, {i}))
		end
	end

	return val
end

function need_table(path, subcheck, required)
	local val = need_type(path, 'table', required, 'be a table')
	if not val then
		return nil
	end

	if subcheck then
		for k, _ in pairs(val) do
			subcheck(extend(path, {k}))
		end
	end

	return val
end

function need_value(path, value, required)
	return need(path, function(v)
		return v == value
	end, required, 'be ' .. tostring(value))
end

function need_one_of(path, array, required)
	return need(path, check_one_of(array), required, 'be one of the given array ' .. array_to_string(array))
end

function need_string_array(path, required)
	return need_array(path, need_string, required)
end

function need_string_array_match(path, pat, required)
	return need_array(path, function(e) need_string_match(e, pat) end, required)
end

function need_array_of(path, array, required)
	return need_array(path, function(e) need_one_of(e, array) end, required)
end

function need_domain_name(path)
	need_string(path)
	need(path, function(domain_name)
		local f = io.open(os.getenv('IPKG_INSTROOT') .. '/lib/gluon/domains/' .. domain_name .. '.json')
		if not f then return false end
		f:close()
		return true
	end, nil, 'be a valid domain name')
end

function obsolete(path, msg)
	local val = loadvar(path)
	if val == nil then
		return nil
	end

	if not msg then
		msg = 'Check the release notes and documentation for details.'

	end

	config_error(conf_src(path), '%s is obsolete. %s', path_to_string(path), msg)
end

local check = assert(loadfile())

site = load_json(os.getenv('IPKG_INSTROOT') .. '/lib/gluon/site.json')

local ok, err = pcall(function()
	if has_domains then
		for k, v in pairs(get_domains()) do
			domain_code = k
			domain = v
			conf = merge(site, domain)
			check()
		end
	else
		conf = site
		check()
	end
end)

if not ok then
	io.stderr:write('*** ', err, '\n')
	os.exit(1)
end
