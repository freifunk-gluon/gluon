local function loader()
   coroutine.yield('return ')
   coroutine.yield(io.open(os.getenv('GLUONDIR') .. '/site/site.conf'):read('*a'))
end

-- setfenv doesn't work with Lua 5.2 anymore, but we're using 5.1
config = setfenv(assert(load(coroutine.wrap(loader), 'site.conf')), {})()
