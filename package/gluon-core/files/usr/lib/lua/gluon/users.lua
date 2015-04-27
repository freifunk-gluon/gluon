local util = require 'gluon.util'

local os = os
local string = string


module 'gluon.users'

function add_user(username, uid, gid)
	util.lock('/var/lock/passwd')
	util.replace_prefix('/etc/passwd', username .. ':', string.format('%s:*:%u:%u::/var:/bin/false\n', username, uid, gid))
	util.replace_prefix('/etc/shadow', username .. ':', string.format('%s:*:0:0:99999:7:::\n', username))
	util.unlock('/var/lock/passwd')
end

function remove_user(username)
	util.lock('/var/lock/passwd')
	util.replace_prefix('/etc/passwd', username .. ':')
	util.replace_prefix('/etc/shadow', username .. ':')
	util.unlock('/var/lock/passwd')
end

function add_group(groupname, gid)
	util.lock('/var/lock/group')
	util.replace_prefix('/etc/group', groupname .. ':', string.format('%s:x:%u:\n', groupname, gid))
	util.unlock('/var/lock/group')
end

function remove_group(groupname)
	util.lock('/var/lock/group')
	util.replace_prefix('/etc/group', groupname .. ':')
	util.unlock('/var/lock/group')
end
