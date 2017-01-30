local util = require 'gluon.util'


module 'gluon.sysctl'

function set(name, value)
	local new
	if value then
		new = name .. '=' .. value .. '\n'
	end
	util.replace_prefix('/etc/sysctl.conf', name .. '=', new)
end
