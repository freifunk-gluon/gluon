local json = require 'jsonc'

local function config_error(src, ...)
	error(src .. ' error: ' .. string.format(...), 0)
end

local has_domains = (os.execute('ls -d "$IPKG_INSTROOT"/lib/gluon/domains/ >/dev/null 2>&1') == 0)
local has_custom = (os.execute('test -e "$IPKG_INSTROOT"/lib/gluon/custom.json') == 0)


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

local site, domain_code, domain, custom, conf


local M = setmetatable({}, { __index = _G })


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
	return table.concat(path, '.')
end

local function format(val)
	if type(val) == 'string' then
		return string.format('%q', val)
	else
		return tostring(val)
	end
end

local function array_to_string(array)
	local strings = {}
	for i, v in ipairs(array) do
		strings[i] = format(v)
	end
	return '[' .. table.concat(strings, ', ') .. ']'
end

function M.table_keys(tbl)
	local keys = {}
	for k in pairs(tbl) do
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

local function custom_src()
	return 'custom.json'
end

local function config_contains(config, path)
	-- A more precise name would be config_exists_and_contains(...), but we want
	-- to keep the name short here.
	if config == 'custom' then
		return has_custom and loadpath(nil, custom, unpack(path)) ~= nil
	elseif config == 'domain' then
		return has_domains and loadpath(nil, domain, unpack(path)) ~= nil
	elseif config == 'site' then
		return loadpath(nil, site, unpack(path)) ~= nil
	else
		assert(false)
	end
end

local function conf_src(path, skip)
	local sources = {}

	if skip ~= 'custom' and config_contains('custom', path) then
		table.insert(sources, custom_src())
	elseif skip ~= 'domain' and config_contains('domain', path) then
		table.insert(sources, domain_src())
	elseif skip ~= 'site' and config_contains('site', path) then
		table.insert(sources, site_src())
	else
		-- path not found, so show all possible sources
		if skip ~= 'site' then
			table.insert(sources, site_src())
		end

		if skip ~= 'domain' and has_domains then
			table.insert(sources, domain_src())
		end

		if skip ~= 'custom' and has_custom then
			table.insert(sources, custom_src())
		end
	end

	return table.concat(sources, ' / ')
end

local function var_error(path, val, msg)
	local found = 'unset'
	if val ~= nil then
		found = string.format('%s (a %s value)', format(val), type(val))
	end

	config_error(conf_src(path), 'expected %s to %s, but it is %s', path_to_string(path), msg, found)
end

function M.in_site(path)
	if config_contains('domain', path) or config_contains('custom', path) then
		config_error(conf_src(path, 'site'), '%s is allowed in site configuration only', path_to_string(path))
	end

	return path
end

function M.in_domain(path)
	-- We allow all domain only variables in site, when there is no domain config,
	-- meaning that we only have a single domain inside the site.conf.
	local allowed_in_site = not has_domains

	if (not allowed_in_site and config_contains('site', path)) or config_contains('custom', path) then
		config_error(conf_src(path, 'domain'), '%s is allowed in domain configuration only', path_to_string(path))
	end

	return path
end

function M.in_custom(path)
	if config_contains('site', path) or config_contains('domain', path) then
		config_error(conf_src(path, 'custom'), '%s is allowed in custom configuration only', path_to_string(path))
	end

	return path
end

function M.in_site_or_domain(path)
	if config_contains('custom', path)  then
		config_error(custom_src(), '%s is allowed in site or domain configuration only', path_to_string(path))
	end

	return path
end

function M.in_site_or_custom(path)
	if config_contains('domain', path)  then
		config_error(domain_src(), '%s is allowed in site or custom configuration only', path_to_string(path))
	end

	return path
end

function M.in_domain_or_custom(path)
	-- We allow all domain only variables in site, when there is no domain config,
	-- meaning that we only have a single domain inside the site.conf.
	local allowed_in_site = not has_domains

	if not allowed_in_site and config_contains('site', path)  then
		config_error(site_src(), '%s is allowed in domain or custom configuration only', path_to_string(path))
	end

	return path
end

function M.this_domain()
	return domain_code
end


function M.extend(path, c)
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

	return loadpath(M.extend(path, {c}), base[c], ...)
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


local function check_chanlist(channels)
	local is_valid_channel = check_one_of(channels)
	return function(chanlist)
		for group in chanlist:gmatch("%S+") do
			if group:match("^%d+$") then
				local channel = tonumber(group)
				if not is_valid_channel(channel) then
					return false
				end
			elseif group:match("^%d+-%d+$") then
				local from, to = group:match("^(%d+)-(%d+)$")
				from = tonumber(from)
				to = tonumber(to)
				if from >= to then
					return false
				end
				if not is_valid_channel(from) or not is_valid_channel(to) then
					return false
				end
			else
				return false
			end
		end
		return true
	end
end

function M.need(path, check, required, msg)
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
	return M.need(path, check_type(type), required, msg)
end


function M.need_alphanumeric_key(path)
	local val = path[#path]
	-- We don't use character classes like %w here to be independent of the locale
	if type(val) ~= 'string' or not val:match('^[0-9a-zA-Z_]+$') then
		var_error(path, val, 'have a string key using only alphanumeric characters and underscores')
	end
end


function M.need_string(path, required)
	return need_type(path, 'string', required, 'be a string')
end

function M.need_string_match(path, pat, required)
	local val = M.need_string(path, required)
	if not val then
		return nil
	end

	if not val:match(pat) then
		var_error(path, val, "match pattern '" .. pat .. "'")
	end

	return val
end

function M.need_number(path, required)
	return need_type(path, 'number', required, 'be a number')
end

function M.need_number_range(path, min, max, required)
	local val = need_type(path, 'number', required)
	if not val then
		return nil
	end

	if val < min or val > max then
		var_error(path, val, "be in range [" .. min .. ", " .. max .. "]")
	end

	return val
end

function M.need_boolean(path, required)
	return need_type(path, 'boolean', required, 'be a boolean')
end

function M.need_array(path, subcheck, required)
	local val = need_type(path, 'table', required, 'be an array')
	if not val then
		return nil
	end

	if subcheck then
		for i = 1, #val do
			subcheck(M.extend(path, {i}))
		end
	end

	return val
end

function M.need_table(path, subcheck, required)
	local val = need_type(path, 'table', required, 'be a table')
	if not val then
		return nil
	end

	if subcheck then
		for k, _ in pairs(val) do
			subcheck(M.extend(path, {k}))
		end
	end

	return val
end

function M.need_value(path, value, required)
	return M.need(path, function(v)
		return v == value
	end, required, 'be ' .. tostring(value))
end

function M.need_one_of(path, array, required)
	return M.need(path, check_one_of(array), required, 'be one of the given array ' .. array_to_string(array))
end

function M.need_string_array(path, required)
	return M.need_array(path, M.need_string, required)
end

function M.need_string_array_match(path, pat, required)
	return M.need_array(path, function(e) M.need_string_match(e, pat) end, required)
end

function M.need_array_of(path, array, required)
	return M.need_array(path, function(e) M.need_one_of(e, array) end, required)
end

function M.need_chanlist(path, channels, required)
	local valid_chanlist = check_chanlist(channels)
	return M.need(path, valid_chanlist, required,
		'be a space-separated list of WiFi channels or channel-ranges (separated by a hyphen). '
		.. 'Valid channels are: ' .. array_to_string(channels))
end

function M.need_domain_name(path)
	M.need_string(path)
	M.need(path, function(domain_name)
		local f = io.open((os.getenv('IPKG_INSTROOT') or '') .. '/lib/gluon/domains/' .. domain_name .. '.json')
		if not f then return false end
		f:close()
		return true
	end, nil, 'be a valid domain name')
end

function M.obsolete(path, msg)
	local val = loadvar(path)
	if val == nil then
		return nil
	end

	if not msg then
		msg = 'Check the release notes and documentation for details.'

	end

	config_error(conf_src(path), '%s is obsolete. %s', path_to_string(path), msg)
end

local check = setfenv(assert(loadfile()), M)

site = assert(json.load((os.getenv('IPKG_INSTROOT') or '') .. '/lib/gluon/site.json'))

if has_custom then
	custom = json.load(os.getenv('IPKG_INSTROOT') .. '/lib/gluon/custom.json')
	print('Found ' .. os.getenv('IPKG_INSTROOT') .. '/lib/gluon/custom.json!')
else
	print('Info: ' .. os.getenv('IPKG_INSTROOT') .. '/lib/gluon/custom.json is not existing.')
end

local ok, err = pcall(function()
	if has_domains then
		for k, v in pairs(get_domains()) do
			domain_code = k
			domain = v
			conf = merge(site, domain)
			if has_custom then
				conf = merge(conf, custom)
			end
			check()
		end
	else
		conf = site
		if has_custom then
			conf = merge(conf, custom)
		end
		check()
	end
end)

if not ok then
	io.stderr:write('*** ', err, '\n')
	os.exit(1)
end
