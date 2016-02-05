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

local m = Map("system", translate("SSH keys"))
m.pageaction = false
m.template = "admin/expertmode"

if fs.access("/etc/config/dropbear") then
  local s = m:section(TypedSection, "_dummy1", nil,
                      translate("You can provide your SSH keys here (one per line):"))

  s.addremove = false
  s.anonymous = true

  function s.cfgsections()
    return { "_keys" }
  end

  local keys

  keys = s:option(TextValue, "_data", "")
  keys.wrap    = "off"
  keys.rows    = 5
  keys.rmempty = true

  function keys.cfgvalue()
    return fs.readfile("/etc/dropbear/authorized_keys") or ""
  end

  function keys.write(self, section, value)
    if value then
      fs.writefile("/etc/dropbear/authorized_keys", value:gsub("\r\n", "\n"):trim() .. "\n")
    end
  end

  function keys.remove(self, section)
    if keys:formvalue("_keys") then
      fs.remove("/etc/dropbear/authorized_keys")
    end
  end
end

local m2 = Map("system", translate("Password"))
m2.reset = false
m2.pageaction = false
m2.template = "admin/expertmode"

local s = m2:section(TypedSection, "_dummy2", nil, translate(
                       "Alternatively, you can set a password to access you node. Please choose a secure password you don't use anywhere else.<br /><br />"
                         .. "If you set an empty password, login via password will be disabled. This is the default."))

s.addremove = false
s.anonymous = true

local pw1 = s:option(Value, "pw1", translate("Password"))
pw1.password = true

local pw2 = s:option(Value, "pw2", translate("Confirmation"))
pw2.password = true

function s.cfgsections()
  return { "_pass" }
end

function m2.on_commit(map)
  local v1 = pw1:formvalue("_pass")
  local v2 = pw2:formvalue("_pass")

  if v1 and v2 then
    if v1 == v2 then
      if #v1 > 0 then
        if luci.sys.user.setpasswd('root', v1) == 0 then
          m2.message = translate("Password changed.")
        else
          m2.errmessage = translate("Unable to change the password.")
        end
      else
        -- We don't check the return code here as the error 'password for root is already locked' is normal...
        os.execute('passwd -l root >/dev/null')
        m2.message = translate("Password removed.")
      end
    else
      m2.errmessage = translate("The password and the confirmation differ.")
    end
  end
end

local c = Compound(m, m2)
c.pageaction = false
return c
