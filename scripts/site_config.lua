local site = os.getenv('GLUON_SITEDIR') .. '/'

return function(config)
	local function loader()
		coroutine.yield('return ')
		coroutine.yield(io.open(site..config):read('*a'))
	end

	-- setfenv doesn't work with Lua 5.2 anymore, but we're using 5.1
	return setfenv(assert(load(coroutine.wrap(loader), config)), {})()
end
