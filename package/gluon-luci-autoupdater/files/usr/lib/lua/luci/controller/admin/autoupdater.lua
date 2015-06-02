--[[
LuCI - Lua Configuration Interface

Copyright 2013 Nils Schneider <nils@nilsschneider.net>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--

module("luci.controller.admin.autoupdater", package.seeall)

function index()
        entry({"admin", "autoupdater"}, cbi("admin/autoupdater"), _("Automatic updates"), 80)
end
