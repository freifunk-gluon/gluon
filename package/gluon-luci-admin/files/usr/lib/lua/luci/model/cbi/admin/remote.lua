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

local m = Map("system", "SSH-Keys")
m.submit = "Speichern"
m.reset = "Zurücksetzen"
m.pageaction = false
m.template = "admin/expertmode"

if fs.access("/etc/config/dropbear") then
  local s = m:section(TypedSection, "_dummy1", nil,
    "Hier hast du die Möglichkeit SSH-Keys (einen pro Zeile) zu hinterlegen:")

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
      fs.writefile("/etc/dropbear/authorized_keys", value:gsub("\r\n", "\n"))
    end
  end

  function keys.remove(self, section)
    fs.remove("/etc/dropbear/authorized_keys")
  end
end

local m2 = Map("system", "Passwort")
m2.submit = "Speichern"
m2.reset = false
m2.pageaction = false
m2.template = "admin/expertmode"

local s = m2:section(TypedSection, "_dummy2", nil,
[[Alternativ kannst du auch ein Passwort setzen. Wähle bitte ein sicheres Passwort, das du nirgendwo anders verwendest.<br /><br />
Beim Setzen eines leeren Passworts wird der Login per Passwort gesperrt (dies ist die Standard-Einstellung).]])

s.addremove = false
s.anonymous = true

local pw1 = s:option(Value, "pw1", "Passwort")
pw1.password = true

local pw2 = s:option(Value, "pw2", "Wiederholung")
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
	if luci.sys.user.setpasswd(luci.dispatcher.context.authuser, v1) == 0 then
          m2.message = "Passwort geändert."
	else
          m2.errmessage = "Das Passwort konnte nicht geändert werden."
	end
      else
        -- We don't check the return code here as the error 'password for root is already locked' is normal...
        os.execute('passwd -l root >/dev/null')
        m2.message = "Passwort gelöscht."
      end
    else
      m2.errmessage = "Die beiden Passwörter stimmen nicht überein."
    end
  end
end

local c = Compound(m, m2)
c.pageaction = false
return c
