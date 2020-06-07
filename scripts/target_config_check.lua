local errors = false

local function fail(msg)
	if not errors then
		errors = true
		io.stderr:write('Configuration failed:', '\n')
	end

	io.stderr:write(' * ', msg, '\n')
end

local function match_config(expected, actual)
	if expected == actual then
		return true
	end

	if expected:gsub('=m$', '=y') == actual then
		return true
	end

	return false
end

local function check_config(config)
	for line in io.lines('openwrt/.config') do
		if match_config(config, line) then
			return true
		end
	end

	return false
end


local lib = dofile('scripts/target_config_lib.lua')

for _, config in pairs(lib.configs) do
	if config.required then
		if not check_config(config:format()) then
			fail(config.required)
		end
	end
end

if errors then
	os.exit(1)
end
