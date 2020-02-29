local funcs = {}

function funcs.config_message(config, _, ...)
	config(...)
end

function funcs.config_package(config, pkg, value)
	config('CONFIG_PACKAGE_%s=%s', pkg, value)
end

local lib = dofile('scripts/target_config_lib.lua')(funcs)


local output = {}

for config in pairs(lib.configs) do
	table.insert(output, config)
	io.stderr:write(string.format("target_config.lua:config# %s\n", config))
end

-- The sort will make =y entries override =m ones
table.sort(output)
io.stderr:write("target_config.lua: outputting openwrt-config ...\n")
for _, line in ipairs(output) do
	io.stdout:write(line, '\n')
end
