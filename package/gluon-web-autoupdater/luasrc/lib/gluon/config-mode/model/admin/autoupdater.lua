--[[
Copyright 2013 Nils Schneider <nils@nilsschneider.net>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0
]]--

local uci = require("simple-uci").cursor()
local autoupdater = uci:get_first("autoupdater", "autoupdater")
local util = require 'gluon.util'

local f = Form(translate("Automatic updates"))

if not util.in_setup_mode() then
	f.submit = translate('Save & apply')
end

local s = f:section(Section)
local o

o = s:option(Flag, "enabled", translate("Enable"))
o.default = uci:get_bool("autoupdater", autoupdater, "enabled")
function o:write(data)
	uci:set("autoupdater", autoupdater, "enabled", data)
end

o = s:option(ListValue, "branch", translate("Branch"))

local branches = {}
uci:foreach("autoupdater", "branch", function(branch)
	table.insert(branches, branch)
end)
table.sort(branches, function(a, b)
	return a.name < b.name
end)
for _, branch in ipairs(branches) do
	o:value(branch[".name"], branch.name)
end

o.default = uci:get("autoupdater", autoupdater, "branch")
function o:write(data)
	uci:set("autoupdater", autoupdater, "branch", data)
end

function f:write()
	uci:commit("autoupdater")

	if not util.in_setup_mode() then
		util.reconfigure_asynchronously()
	end
end

return f
