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
	if val then
		local f = io.open(sysconfigdir .. name, 'w+')
		f:write(val)
		f:close()
	else
		os.remove(sysconfigdir .. name)
	end
end

local setmetatable = setmetatable

module 'gluon.sysconfig'

setmetatable(_M,
	{
		__index = get,
		__newindex = set,
	}
)

return _M
