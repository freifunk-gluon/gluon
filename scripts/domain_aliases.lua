local cjson = require 'cjson'

local function load_json(filename)
	local f = assert(io.open(filename))
	local json = cjson.decode(f:read('*a'))
	f:close()
	return json
end

local domain = load_json(arg[1])
for k, _ in pairs(domain.domain_names) do
	print(k)
end
