local site = require 'gluon.site'

local setmetatable = setmetatable

module 'gluon.site_config'

setmetatable(_M, {
	__index = site(),
})

return _M
