
local function contains(table, val)
	for i=1,#table do
		if table[i] == val then
			return true
		end
	end
	return false
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

local Validator = {}

function Validator:new(data, var_error)
	local o = {
		data = data,
	}
	if var_error then
		o.var_error = var_error
	end
	setmetatable(o, self)
	self.__index = self
	return o
end

local function extend(path, c)
	if not path then return nil end

	local p = {unpack(path)}

	for _, e in ipairs(c) do
		p[#p+1] = e
	end
	return p
end

function Validator:extend(path, c)
	return extend(path, c)
end

function Validator:loadpath(path, base, c, ...)
	if not c or base == nil then
		return base
	end

	if type(base) ~= 'table' then
		if path then
			self:var_error(path, base, 'be a table')
		else
			return nil
		end
	end

	return self:loadpath(extend(path, {c}), base[c], ...)
end

function Validator.format(...)
	return format(...)
end

function Validator:loadvar(path)
	if path.is_value then
		return path.value
	end

	return self:loadpath({}, self.data, unpack(path))
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

function Validator:need(path, check, required, msg)
	local val = self:loadvar(path)
	if required == false and val == nil then
		return nil
	end

	if not check(val) then
		self:var_error(path, val, msg)
	end

	return val
end

function Validator:need_type(path, type, required, msg)
	return self:need(path, check_type(type), required, msg)
end

function Validator:need_alphanumeric_key(path)
	local val = path[#path]
	-- We don't use character classes like %w here to be independent of the locale
	if type(val) ~= 'string' or not val:match('^[0-9a-zA-Z_]+$') then
		self:var_error(path, val, 'have a string key using only alphanumeric characters and underscores')
	end
end

function Validator:need_string(path, required)
	return self:need_type(path, 'string', required, 'be a string')
end

function Validator:need_string_match(path, pat, required)
	local val = self:need_string(path, required)
	if not val then
		return nil
	end

	if not val:match(pat) then
		self:var_error(path, val, "match pattern '" .. pat .. "'")
	end

	return val
end

function Validator:need_number(path, required)
	return self:need_type(path, 'number', required, 'be a number')
end

function Validator:need_number_range(path, min, max, required)
	local val = self:need_number(path, required)
	if not val then
		return nil
	end

	if val < min or val > max then
		self:var_error(path, val, "be in range [" .. min .. ", " .. max .. "]")
	end

	return val
end

function Validator:need_boolean(path, required)
	return self:need_type(path, 'boolean', required, 'be a boolean')
end

function Validator:need_array(path, subcheck, required)
	local val = self:need_type(path, 'table', required, 'be an array')
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

function Validator:need_table(path, subcheck, required)
	local val = self:need_type(path, 'table', required, 'be a table')
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

function Validator:need_value(path, value, required)
	return self:need(path, function(v)
		return v == value
	end, required, 'be ' .. tostring(value))
end

function Validator:need_one_of(path, array, required)
	return self:need(path, check_one_of(array), required, 'be one of the given array ' .. array_to_string(array))
end

function Validator:need_string_array(path, required)
	return self:need_array(path, function(e) self:need_string(e) end, required)
end

function Validator:need_string_array_match(path, pat, required)
	return self:need_array(path, function(e) self:need_string_match(e, pat) end, required)
end

function Validator:need_array_of(path, array, required)
	return self:need_array(path, function(e) self:need_one_of(e, array) end, required)
end

function Validator:need_array_elements_exclusive(path, a, b, required)
	local val = self:need_array(path, nil, required)
	if not val then
		return nil
	end

	if contains(val, a) and contains(val, b) then
		self:var_error(path, val, 'contain only one of the elements '
			.. format(a) .. ' and ' .. format(b) .. ', but not both.')
	end

	return val
end

function Validator:need_chanlist(path, channels, required)
	local valid_chanlist = check_chanlist(channels)
	return self:need(path, valid_chanlist, required,
		'be a space-separated list of WiFi channels or channel-ranges (separated by a hyphen). '
		.. 'Valid channels are: ' .. array_to_string(channels))
end

function Validator:need_domain_name(path)
	self:need_string(path)
	self:need(path, function(domain_name)
		local f = io.open((os.getenv('IPKG_INSTROOT') or '') .. '/lib/gluon/domains/' .. domain_name .. '.json')
		if not f then return false end
		f:close()
		return true
	end, nil, 'be a valid domain name')
end

return Validator
