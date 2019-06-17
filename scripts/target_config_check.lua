local ret = 0


local function fail(...)
	if ret == 0 then
		ret = 1
		io.stderr:write('Configuration failed:', '\n')
	end

	io.stderr:write(' * ', string.format(...), '\n')
end

local function match_config(f)
	for line in io.lines('openwrt/.config') do
		if f(line) then
			return true
		end
	end

	return false
end

local function check_config(pattern)
	return match_config(function(line) return line == pattern end)
end

local function check_config_prefix(pattern)
	return match_config(function(line) return string.sub(line, 1, -2) == pattern end)
end


local funcs = {}

function funcs.config_message(_, message, ...)
	local pattern = string.format(...)

	if not check_config(pattern) then
		fail('%s', message)
	end
end

function funcs.config_package(_, pkg, value)
	local pattern = string.format('CONFIG_PACKAGE_%s=%s', pkg, value)
	local res
	if value == 'y' then
		res = check_config(pattern)
	else
		res = check_config_prefix(string.sub(pattern, 1, -2))
	end

	if not res then
		fail("unable to enable package '%s'", pkg)
	end
end

local lib = dofile('scripts/target_config_lib.lua')(funcs)

for config, v in pairs(lib.configs) do
	if v == 2 then
		if not check_config(config) then
			fail("unable to set '%s'", config)
		end
	end
end

os.exit(ret)
