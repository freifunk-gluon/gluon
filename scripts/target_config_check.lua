local errors = false

local function fail(msg)
	if not errors then
		errors = true
		io.stderr:write('Configuration failed:', '\n')
	end

	io.stderr:write(' * ', msg, '\n')
end

local function match_config(f)
	for line in io.lines('openwrt/.config') do
		if f(line) then
			return true
		end
	end

	return false
end

local function check_config(config)
	return match_config(function(line) return line == config end)
end


local lib = dofile('scripts/target_config_lib.lua')()

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
