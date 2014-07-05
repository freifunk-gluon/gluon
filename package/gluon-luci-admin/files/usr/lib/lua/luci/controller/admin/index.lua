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
	local setup_mode = uci_state:get_first("gluon-setup-mode", "setup_mode", "running", "0") == "1"

	-- Disable gluon-luci-admin when setup mode is not enabled
	if not setup_mode then
		return
	end

	local root = node()
	if not root.lock then
		root.target = alias("admin")
		root.index = true
	end

	local page = entry({"admin"}, alias("admin", "index"), "Expert Mode", 10)
	page.sysauth = "root"
	if setup_mode then
		-- force root to be logged in when running in setup_mode
		page.sysauth_authenticator = function() return "root" end
	else
		page.sysauth_authenticator = "htmlauth"
	end
	page.index = true

	entry({"admin", "index"}, cbi("admin/remote"), "Remotezugriff", 1).ignoreindex = true

	if not setup_mode then
		entry({"admin", "logout"}, call("action_logout"), "Logout")
	end
end

function action_logout()
	local dsp = require "luci.dispatcher"
	local sauth = require "luci.sauth"
	if dsp.context.authsession then
		sauth.kill(dsp.context.authsession)
		dsp.context.urltoken.stok = nil
	end

	luci.http.header("Set-Cookie", "sysauth=; path=" .. dsp.build_url())
	luci.http.redirect(luci.dispatcher.build_url())
end
