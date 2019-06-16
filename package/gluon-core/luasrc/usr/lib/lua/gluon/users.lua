local util = require 'gluon.util'


local M = {}

function M.remove_user(username)
	os.execute('exec lock /var/lock/passwd')
	util.replace_prefix('/etc/passwd', username .. ':')
	util.replace_prefix('/etc/shadow', username .. ':')
	os.execute('exec lock -u /var/lock/passwd')
end

function M.remove_group(groupname)
	os.execute('exec lock /var/lock/group')
	util.replace_prefix('/etc/group', groupname .. ':')
	os.execute('exec lock -u /var/lock/group')
end

return M
