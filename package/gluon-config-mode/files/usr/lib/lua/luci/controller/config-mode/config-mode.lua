--[[
Copyright 2013 Nils Schneider <nils@nilsschneider.net>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--

module("luci.controller.config-mode.config-mode", package.seeall)

local meshvpn_name = "mesh_vpn"

function index()
  local uci_state = luci.model.uci.cursor_state()

  if uci_state:get_first("config-mode", "wizard", "running", "0") == "1" then
    local root = node()
    if not root.target then
      root.target = alias("config-mode")
      root.index = true
    end

    page          = node()
    page.lock     = true
    page.target   = alias("config-mode")
    page.subindex = true
    page.index    = false

    page          = node("config-mode")
    page.title    = _("Wizard")
    page.target   = alias("config-mode", "wizard")
    page.order    = 5
    page.setuser  = "root"
    page.setgroup = "root"
    page.index    = true

    entry({"config-mode", "wizard"}, form("config-mode/wizard")).index = true
    entry({"config-mode", "reboot"}, call("action_reboot"))
  end
end

function action_reboot()
  local configmode = require "luci.tools.config-mode"
  local pubkey
  local uci = luci.model.uci.cursor()
  local meshvpn_enabled = uci:get("fastd", meshvpn_name, "enabled", "0")
  if meshvpn_enabled == "1" then
    pubkey = configmode.get_fastd_pubkey(meshvpn_name)
  end
	luci.template.render("config-mode/reboot", {pubkey=pubkey})

  uci:foreach("config-mode", "wizard", function(s)
      uci:set("config-mode", s[".name"], "configured", "1")
    end)
  uci:save("config-mode")
  uci:commit("config-mode")

  luci.sys.reboot()
end
