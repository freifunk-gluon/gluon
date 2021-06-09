local json = require 'jsonc'

local domain = assert(json.load(arg[1]))
for k, _ in pairs(domain.domain_names) do
	print(k)
end
