dofile('scripts/common.inc.lua')


local output = {}


function config(...)
	table.insert(output, string.format(...))
end

try_config = config


function config_message(msg, ...)
	config(...)
end

function config_package(pkg, value)
	config('CONFIG_PACKAGE_%s=%s', pkg, value)
end


dofile('scripts/target_config.inc.lua')


-- The sort will make =y entries override =m ones
table.sort(output)
for _, line in ipairs(output) do
	io.stdout:write(line, '\n')
end
