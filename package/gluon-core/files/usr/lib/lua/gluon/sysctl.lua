local util = require 'gluon.util'


module 'gluon.sysctl'

function set(name, value)
	util.replace_prefix('/etc/sysctl.conf', name .. '=', name .. '=' .. value .. '\n')
end
