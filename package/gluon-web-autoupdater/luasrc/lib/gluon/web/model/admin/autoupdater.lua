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

o = s:option(Value, "minute", translate("Minute"), translate(
	"This value forces the autoupdater to check for updates at the "
	.. "specified minute. Normally there is no need to set this value "
	.. "because it is selected automatically. You may want to set this to "
	.. "a specific value if you have multiple nodes which should not "
	.. "update at the same time."
))
o.datatype = "irange(0, 59)"
o.default = uci:get("gluon", "autoupdater", "minute")
o.optional = true

function o:write(data)
	if data == uci:get("gluon", "autoupdater", "minute") then
		return
	end
	uci:set("gluon", "autoupdater", "minute", data)

	if data then
		local f = io.open("/usr/lib/micron.d/autoupdater", "w")
		f:write(string.format("%i 4 * * * /usr/sbin/autoupdater\n", data))
		f:write(string.format("%i 0-3,5-23 * * * /usr/sbin/autoupdater --fallback\n", data))
		f:close()
	end
end

function f:write()
	uci:commit("autoupdater")
	uci:commit("gluon")
end

return f
