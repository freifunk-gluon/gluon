local cjson = require 'cjson'

local function load_json(filename)
	local f = assert(io.open(filename))
	local json = cjson.decode(f:read('*a'))
	f:close()
	return json
end

local site = load_json(os.getenv('IPKG_INSTROOT') .. '/lib/gluon/site.json')


function in_site(var)
	return var
end

function in_domain(var)
	return var
end


local function path_to_string(path)
	return table.concat(path, '/')
end

local function array_to_string(array)
	return '[' .. table.concat(array, ', ') .. ']'
end

local function var_error(path, val, msg)
	if type(val) == 'string' then
		val = string.format('%q', val)
	end

	print(string.format('*** site.conf error: expected %s to %s, but it is %s', path_to_string(path), msg, tostring(val)))
	os.exit(1)
end


function extend(path, c)
	local p = {unpack(path)}

	for _, e in ipairs(c) do
		p[#p+1] = e
	end
	return p
end

local function loadpath(path, base, c, ...)
	if not c or base == nil then
		return base
	end

	if type(base) ~= 'table' then
		var_error(path, base, 'be a table')
	end

	return loadpath(extend(path, {c}), base[c], ...)
end

local function loadvar(path)
	return loadpath({}, site, unpack(path))
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
	if not val:match('^[0-9a-zA-Z_]+$') then
		var_error(path, val, 'have a key using only alphanumeric characters and underscores')
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


dofile()
