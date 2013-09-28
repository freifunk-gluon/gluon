--[[
Copyright 2013 Nils Schneider <nils@nilsschneider.net>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--

module("luci.controller.configmode.configmode", package.seeall)

local meshvpn_name = "mesh_vpn"

function index()
  local uci_state = luci.model.uci.cursor_state()

  if uci_state:get_first("configmode", "wizard", "running", "0") == "1" then
    local root = node()
    if not root.target then
      root.target = alias("configmode")
      root.index = true
    end

    page          = node()
    page.lock     = true
    page.target   = alias("configmode")
    page.subindex = true
    page.index    = false

    page          = node("configmode")
    page.title    = _("Configmode")
    page.target   = alias("configmode", "wizard")
    page.order    = 5
    page.setuser  = "root"
    page.setgroup = "root"
    page.index    = true

    entry({"configmode", "wizard"}, form("configmode/wizard"), _("Wizard"), 10).index = true
    entry({"configmode", "reboot"}, call("action_reboot"))
  end
end

function action_reboot()
  local configmode = require "luci.tools.configmode"
  local pubkey
  local uci = luci.model.uci.cursor()
  local address = uci:get_first("configmode", "wizard", "keyaddress")
  local meshvpn_enabled = uci:get("fastd", meshvpn_name, "enabled", "0")
  if meshvpn_enabled == "1" then
    pubkey = configmode.get_fastd_pubkey(meshvpn_name)
  end
	luci.template.render("configmode/reboot", {pubkey=pubkey, address=address})

  uci:foreach("configmode", "wizard", function(s)
      uci:set("configmode", s[".name"], "configured", "1")
      uci:set("configmode", s[".name"], "enabled", "0")
    end)
  uci:save("configmode")
  uci:commit("configmode")

  luci.sys.reboot()
end
