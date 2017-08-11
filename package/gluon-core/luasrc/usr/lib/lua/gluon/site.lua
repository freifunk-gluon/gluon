local site = (function()
	local config = '/lib/gluon/site.json'

	local json = require 'luci.jsonc'
	local decoder = json.new()
	local sink = decoder:sink()

	local file = assert(io.open(config))

	while true do
		local chunk = file:read(2048)
		if not chunk or chunk:len() == 0 then break end
		sink(chunk)
	end

	file:close()

	return assert(decoder:get())
end)()


local wrap


local function index(t, k)
	local v = getmetatable(t).value
	if v == nil then return wrap(nil) end
	return wrap(v[k])
end

local function newindex()
	error('attempted to modify site config')
end

local function call(t, def)
	local v = getmetatable(t).value
	if v == nil then return def end
	return v
end

local function _wrap(v, t)
	return setmetatable(t or {}, {
		__index = index,
		__newindex = newindex,
		__call = call,
		value = v,
	})
end

local none = _wrap(nil)


function wrap(v, t)
	if v == nil then return none end
	return _wrap(v, t)
end


module 'gluon.site'

return wrap(site, _M)
