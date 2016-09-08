--[[
LuCI - Lua Configuration Interface

Copyright 2008 Steven Barth <steven@midlink.org>
Copyright 2008 Jo-Philipp Wich <xm@leipzig.freifunk.net>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--

module("luci.controller.admin.index", package.seeall)

function index()
	local uci_state = luci.model.uci.cursor_state()

	-- Disable gluon-luci-admin when setup mode is not enabled
	if uci_state:get_first('gluon-setup-mode', 'setup_mode', 'running', '0') ~= '1' then
		return
	end

	local root = node()
	if not root.lock then
		root.target = alias("admin")
		root.index = true
	end

	local page = entry({"admin"}, alias("admin", "index"), _("Advanced settings"), 10)
	page.sysauth = "root"
	page.sysauth_authenticator = function() return "root" end
	page.index = true

	entry({"admin", "index"}, cbi("admin/info"), _("Information"), 1).ignoreindex = true
	entry({"admin", "remote"}, cbi("admin/remote"), _("Remote access"), 10)
end
