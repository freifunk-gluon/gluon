dofile('scripts/common.inc.lua')


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

function config(...)
	local pattern = string.format(...)

	if not check_config(pattern) then
		fail("unable to set '%s'", pattern)
	end
end

function config_message(message, ...)
	local pattern = string.format(...)

	if not check_config(pattern) then
		fail('%s', message)
	end
end

function config_package(pkg, value)
	local pattern = string.format('CONFIG_PACKAGE_%s=%s', pkg, value)
	local ret
	if value == 'y' then
		res = check_config(pattern)
	else
		res = check_config_prefix(string.sub(pattern, 1, -2))
	end

	if not res then
		fail("unable to enable package '%s'", pkg)
	end
end


dofile('scripts/target_config.inc.lua')


os.exit(ret)
