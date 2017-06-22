--[[
Copyright 2008 Steven Barth <steven@midlink.org>
Copyright 2011 Jo-Philipp Wich <xm@subsignal.org>
Copyright 2013 Nils Schneider <nils@nilsschneider.net>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0
]]--

local nixio = require "nixio"
local fs = require "nixio.fs"
local util = require "gluon.util"
local site = require 'gluon.site_config'

local f_keys = Form(translate("SSH keys"), translate("You can provide your SSH keys here (one per line):"), 'keys')
local s = f_keys:section(Section)
local keys = s:option(TextValue, "keys")
keys.wrap = "off"
keys.rows = 5
keys.default = fs.readfile("/etc/dropbear/authorized_keys") or ""

function keys:write(value)
	value = util.trim(value:gsub("\r", ""))
	if value ~= "" then
		fs.writefile("/etc/dropbear/authorized_keys", value .. "\n")
	else
		fs.remove("/etc/dropbear/authorized_keys")
	end
end

local config = (site.config_mode or {}).remote_login or {}
if not config.show_password_form then
	-- password login is disabled in site.conf
	return f_keys
end

local min_password_length = config.min_password_length or 12
local mintype = 'minlength(' .. min_password_length .. ')'
local length_hint

if min_password_length > 1 then
	length_hint = translatef("%u characters min.", min_password_length)
end

local f_password = Form(translate("Password"), translate(
	"Alternatively, you can set a password to access your node. Please choose a "
	.. "secure password you don't use anywhere else.<br /><br />If you set an empty "
	.. "password, login via password will be disabled. This is the default."
	), 'password'
)
f_password.reset = false

local s = f_password:section(Section)

local pw1 = s:option(Value, "pw1", translate("Password"))
pw1.password = true
pw1.optional = true
pw1.datatype = mintype
function pw1.cfgvalue()
	return ''
end

local pw2 = s:option(Value, "pw2", translate("Confirmation"), length_hint)
pw2.password = true
pw2.optional = true
pw2.datatype = mintype
function pw2.cfgvalue()
	return ''
end

local function set_password(password)
	local inr, inw = nixio.pipe()
	local pid = nixio.fork()

	if pid < 0 then
		return false
	elseif pid == 0 then
		inw:close()

		local null = nixio.open('/dev/null', 'w')
		nixio.dup(null, nixio.stderr)
		nixio.dup(null, nixio.stdout)
		if null:fileno() > 2 then
			null:close()
		end

		nixio.dup(inr, nixio.stdin)
		inr:close()

		nixio.execp('passwd')
		os.exit(127)
	end

	inr:close()

	inw:write(string.format('%s\n%s\n', password, password))
	inw:close()

	local wpid, status, code = nixio.waitpid(pid)
	return wpid and status == 'exited' and code == 0
end

function f_password:write()
	if pw1.data ~= pw2.data then
		f_password.errmessage = translate("The password and the confirmation differ.")
		return
	end

	local pw = pw1.data

	if pw ~= nil and #pw > 0 then
		if set_password(pw) then
			f_password.message = translate("Password changed.")
		else
			f_password.errmessage = translate("Unable to change the password.")
		end
	else
		-- We don't check the return code here as the error 'password for root is already locked' is normal...
		os.execute('passwd -l root >/dev/null')
		f_password.message = translate("Password removed.")
	end
end

return f_keys, f_password
