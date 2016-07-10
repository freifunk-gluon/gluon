local function get_site_config()
  local config = '/lib/gluon/site.json'

  local json = require 'luci.jsonc'
  local ltn12 = require 'luci.ltn12'

  local file = assert(io.open(config))

  local decoder = json.new()
  ltn12.pump.all(ltn12.source.file(file), decoder:sink())

  file:close()

  return assert(decoder:get())
end

local setmetatable = setmetatable

module 'gluon.site_config'

setmetatable(_M,
	{
		__index = get_site_config(),
	}
)

return _M
