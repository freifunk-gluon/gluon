-- SPDX-FileCopyrightText: 2013 Nils Schneider <nils@nilsschneider.net>
-- SPDX-License-Identifier: Apache-2.0

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
end

return f
