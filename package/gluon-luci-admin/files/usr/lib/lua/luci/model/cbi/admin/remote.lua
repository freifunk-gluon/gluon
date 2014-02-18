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

local m, s, pw1, pw2

m = Map("system", "Remotezugriff")
m.submit = "Speichern"
m.reset = "Zurücksetzen"
m.pageaction = false
m.template = "admin/expertmode"

if fs.access("/etc/config/dropbear") then
  s = m:section(TypedSection, "_keys", nil,
    "Here you can paste public SSH-Keys (one per line) for SSH public-key authentication.")

  s.addremove = false
  s.anonymous = true

  function s.cfgsections()
    return { "_keys" }
  end

  local keys

  keys = s:option(TextValue, "_data", "")
  keys.wrap    = "off"
  keys.rows    = 5
  keys.rmempty = false

  function keys.cfgvalue()
    return fs.readfile("/etc/dropbear/authorized_keys") or ""
  end

  function keys.write(self, section, value)
    if value then
      fs.writefile("/etc/dropbear/authorized_keys", value:gsub("\r\n", "\n"))
    end
  end
end

s = m:section(TypedSection, "_pass", nil,
  "Changes the administrator password for accessing the device")

s.addremove = false
s.anonymous = true

pw1 = s:option(Value, "pw1", "Password")
pw1.password = true

pw2 = s:option(Value, "pw2", "Confirmation")
pw2.password = true

function s.cfgsections()
  return { "_pass" }
end

function m.on_commit(map)
  local v1 = pw1:formvalue("_pass")
  local v2 = pw2:formvalue("_pass")

  if v1 and v2 and #v1 > 0 and #v2 > 0 then
    if v1 == v2 then
      if luci.sys.user.setpasswd(luci.dispatcher.context.authuser, v1) == 0 then
        m.message = "Password successfully changed!"
      else
        m.errmessage = "Unknown Error, password not changed!"
      end
    else
      m.errmessage = "Given password confirmation did not match, password not changed!"
    end
  end
end

return m
