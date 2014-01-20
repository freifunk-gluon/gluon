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

s = m:section(TypedSection, "autoupdater", "Einstelleungen")
s.addremove = false

s:option(Flag, "enabled", "Aktivieren")
f = s:option(ListValue, "branch", "Branch")

uci.cursor():foreach("autoupdater", "branch", function (section) f:value(section[".name"]) end)

s = m:section(TypedSection, "branch", "Branches")
s.addremove = true

s:option(DynamicList, "mirror", "Mirrors")
s:option(Value, "probability", "Update Wahrscheinlichkeit")
s:option(Value, "good_signatures", "Benötigte Signaturen")

o = s:option(DynamicList, "pubkey", "Public Keys")

return m

