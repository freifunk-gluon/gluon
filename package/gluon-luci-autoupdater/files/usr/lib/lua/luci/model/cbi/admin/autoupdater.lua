--[[
LuCI - Lua Configuration Interface

Copyright 2013 Nils Schneider <nils@nilsschneider.net>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--

m = Map("autoupdater", "Autoupdater")
m.submit = "Speichern"
m.reset = "Zurücksetzen"
m.pageaction = false
m.template = "admin/expertmode"

s = m:section(TypedSection, "autoupdater", nil)
s.addremove = false
s.anonymous = true

s:option(Flag, "enabled", "Aktivieren")
f = s:option(ListValue, "branch", "Branch")

uci.cursor():foreach("autoupdater", "branch", function (section) f:value(section[".name"]) end)

return m

