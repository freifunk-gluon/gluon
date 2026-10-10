local util = require 'gluon.util'

local M = {}

-- olsrd plugins carry their version in the file name
-- (olsrd_jsoninfo.so.1.1), and the LoadPlugin section needs that name
function M.find_module_version(mod)
	local path = util.glob('/usr/lib/' .. mod .. '.so.*')[1]
	if not path then
		error('olsrd plugin ' .. mod .. ' not found')
	end
	return path:match('[^/]+$')
end

return M
