local config = os.getenv('GLUON_SITE_CONFIG') or '/lib/gluon/site.conf'

local function loader()
   coroutine.yield('return ')
   coroutine.yield(io.open(config):read('*a'))
end

-- setfenv doesn't work with Lua 5.2 anymore, but we're using 5.1
local site_config = setfenv(assert(load(coroutine.wrap(loader), 'site.conf')), {})()

local setmetatable = setmetatable

module 'gluon.site_config'

setmetatable(_M,
	{
		__index = site_config,
	}
)

return _M
