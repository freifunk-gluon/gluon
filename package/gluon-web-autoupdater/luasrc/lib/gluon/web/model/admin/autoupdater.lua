--[[
Copyright 2013 Nils Schneider <nils@nilsschneider.net>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0
]]--

local uci = require("simple-uci").cursor()
local autoupdater = uci:get_first("autoupdater", "autoupdater")

local f = Form(translate("Automatic updates"))
local s = f:section(Section)
local o

o = s:option(Flag, "enabled", translate("Enable"))
o.default = uci:get_bool("autoupdater", autoupdater, "enabled")
function o:write(data)
	uci:set("autoupdater", autoupdater, "enabled", data)
end

o = s:option(ListValue, "branch", translate("Branch"))
uci:foreach("autoupdater", "branch",
	function (section)
		o:value(section[".name"])
	end
)
o.default = uci:get("autoupdater", autoupdater, "branch")
function o:write(data)
	uci:set("autoupdater", autoupdater, "branch", data)
end

function f:write()
	uci:commit("autoupdater")
end

return f
