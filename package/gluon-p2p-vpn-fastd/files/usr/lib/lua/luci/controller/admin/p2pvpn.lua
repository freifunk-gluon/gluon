--[[
LuCI - Lua Configuration Interface

Copyright 2013 Nils Schneider <nils@nilsschneider.net>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--

module("luci.controller.admin.p2pvpn", package.seeall)

function index()
        entry({"admin", "p2pvpn"}, cbi("admin/p2pvpn"), _("P2P VPN"), 80)
end
