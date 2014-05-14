local sysconfigdir = '/lib/gluon/core/sysconfig/'

local function get(_, name)
	local ret = nil
	local f = io.open(sysconfigdir .. name)
	if f then
		ret = f:read('*line')
		f:close()
	end
	return ret
end

local function set(_, name, val)
	local ret = nil
	local f = io.open(sysconfigdir .. name, 'w+')
	f:write(val)
	f:close()
end

local sysconfig = {}
local mt = {
	__index = get,
	__newindex = set,
}

setmetatable(sysconfig, mt)
return sysconfig
