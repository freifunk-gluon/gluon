--[[
LuCI - Lua Configuration Interface

Copyright 2008 Steven Barth <steven@midlink.org>
Copyright 2011 Jo-Philipp Wich <xm@subsignal.org>
Copyright 2013 Nils Schneider <nils@nilsschneider.net>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--

local fs = require "nixio.fs"

local f_keys = SimpleForm('keys', translate("SSH keys"), translate("You can provide your SSH keys here (one per line):"))
f_keys.hidden = { submit_keys = '1' }

local keys

keys = f_keys:field(TextValue, "keys", "")
keys.wrap    = "off"
keys.rows    = 5
keys.rmempty = true

function keys.cfgvalue()
	return fs.readfile("/etc/dropbear/authorized_keys") or ""
end

function keys.write(self, section, value)
	if not f_keys:formvalue('submit_keys') then return end

	fs.writefile("/etc/dropbear/authorized_keys", value:gsub("\r\n", "\n"):trim() .. "\n")
end

function keys.remove(self, section)
	if not f_keys:formvalue('submit_keys') then return end

	fs.remove("/etc/dropbear/authorized_keys")
end

local f_password = SimpleForm('password', translate("Password"),
	translate(
                "Alternatively, you can set a password to access you node. Please choose a secure password you don't use anywhere else.<br /><br />"
                .. "If you set an empty password, login via password will be disabled. This is the default."
	)
)
f_password.hidden = { submit_password = '1' }
f_password.reset = false

local pw1 = f_password:field(Value, "pw1", translate("Password"))
pw1.password = true
function pw1.cfgvalue()
	return ''
end

local pw2 = f_password:field(Value, "pw2", translate("Confirmation"))
pw2.password = true
function pw2.cfgvalue()
	return ''
end

function f_password:handle(state, data)
	if not f_password:formvalue('submit_password') then return end

	if data.pw1 ~= data.pw2 then
		f_password.errmessage = translate("The password and the confirmation differ.")
		return
	end

	if data.pw1 and #data.pw1 > 0 then
		if luci.sys.user.setpasswd('root', data.pw1) == 0 then
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
