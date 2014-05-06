--[[
LuCI - Lua Configuration Interface

Copyright 2014 Nils Schneider <nils@nilsschneider.net>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--

local uci = luci.model.uci.cursor()

f = SimpleForm("portconfig")
f.template = "admin/expertmode"
f.submit = "Speichern"
f.reset = "Zurücksetzen"

s = f:section(SimpleSection, nil, nil)

o = s:option(Flag, "mesh_wan", "Mesh auf dem WAN-Port aktivieren")
o.default = uci:get_bool("network", "mesh_wan", "auto") and o.enabled or o.disabled
o.rmempty = false

function f.handle(self, state, data)
  if state == FORM_VALID then
    uci:set("network", "mesh_wan", "auto", data.mesh_wan)
    uci:save("network")
    uci:commit("network")
  end

  return true
end

return f
