local function read_json(path)

	local json = require 'luci.jsonc'
	local decoder = json.new()
	local sink = decoder:sink()

	local file = assert(io.open(path))

	while true do
		local chunk = file:read(2048)
		if not chunk or chunk:len() == 0 then break end
		sink(chunk)
	end

	file:close()

	return assert(decoder:get())
end

local site = read_json('/lib/gluon/site.json')
local domain = (function(site)
	local uci = require('simple-uci').cursor()
	local fs = require "nixio.fs"
	local sname = uci:get_first('gluon', 'system')

	local dc = uci:get('gluon', sname, 'domain_code') or ''

	if fs.stat('/lib/gluon/domains/'..dc..'.json', 'type')~='reg' then
		dc = site['default_domain_code']
	end

	local domain = read_json('/lib/gluon/domains/'..dc..'.json')
	if domain['domain_aliases'] and domain['domain_aliases'][dc] then
		domain['domain_name'] = domain['domain_aliases'][dc]
	end
	return domain
end)(site)


local wrap

local function merge(t1, t2)
	for k, v in pairs(t2) do
		if (type(v) == "table") and (type(t1[k] or false) == "table") then
			merge(t1[k], t2[k])
		else
			t1[k] = v
		end
	end
	return t1
end

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

return wrap(merge(site, domain), _M)
