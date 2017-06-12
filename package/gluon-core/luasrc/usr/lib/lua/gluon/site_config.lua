local function get_site_config()
	local config = '/lib/gluon/site.json'

	local json = require 'luci.jsonc'
	local decoder = json.new()
	local sink = decoder:sink()

	local file = assert(io.open(config))

	while true do
		local chunk = file:read(2048)
		if not chunk or chunk:len() == 0 then break end
		sink(chunk)
	end

	file:close()

	return assert(decoder:get())
end

local setmetatable = setmetatable

module 'gluon.site_config'

setmetatable(_M, {
	__index = get_site_config(),
})

return _M
