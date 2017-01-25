--[[
LuCI - Lua Configuration Interface

Copyright 2013 Nils Schneider <nils@nilsschneider.net>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--

local uci = require("simple-uci").cursor()
local autoupdater = uci:get_first("autoupdater", "autoupdater")

local f = SimpleForm("autoupdater", translate("Automatic updates"))
local s = f:section(SimpleSection, nil, nil)
local o

o = s:option(Flag, "enabled", translate("Enable"))
o.default = uci:get_bool("autoupdater", autoupdater, "enabled") and o.enabled or o.disabled
o.rmempty = false

o = s:option(ListValue, "branch", translate("Branch"))
uci:foreach("autoupdater", "branch",
	function (section)
		o:value(section[".name"])
	end
)
o.default = uci:get("autoupdater", autoupdater, "branch")

function f.handle(self, state, data)
	if state ~= FORM_VALID then
		return
	end

	uci:set("autoupdater", autoupdater, "enabled", data.enabled)
	uci:set("autoupdater", autoupdater, "branch", data.branch)

	uci:save("autoupdater")
	uci:commit("autoupdater")
end

return f
