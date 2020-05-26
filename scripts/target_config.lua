local lib = dofile('scripts/target_config_lib.lua')

for _, config in pairs(lib.configs) do
	io.stdout:write(config:format(), '\n')
end
