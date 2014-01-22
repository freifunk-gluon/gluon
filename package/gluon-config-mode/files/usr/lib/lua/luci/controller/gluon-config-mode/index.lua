--[[
Copyright 2013 Nils Schneider <nils@nilsschneider.net>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--

module("luci.controller.gluon-config-mode.index", package.seeall)

local meshvpn_name = "mesh_vpn"

function index()
  local uci_state = luci.model.uci.cursor_state()

  if uci_state:get_first("gluon-config-mode", "wizard", "running", "0") == "1" then
    local root = node()
    if not root.target then
      root.target = alias("gluon-config-mode")
      root.index = true
    end

    page          = node()
    page.lock     = true
    page.target   = alias("gluon-config-mode")
    page.subindex = true
    page.index    = false

    page          = node("gluon-config-mode")
    page.title    = _("Wizard")
    page.target   = alias("gluon-config-mode", "wizard")
    page.order    = 5
    page.setuser  = "root"
    page.setgroup = "root"
    page.index    = true

    entry({"gluon-config-mode", "wizard"}, form("gluon-config-mode/wizard")).index = true
    entry({"gluon-config-mode", "reboot"}, call("action_reboot"))
  end
end

function action_reboot()
  local configmode = require "luci.tools.gluon-config-mode"
  local pubkey
  local uci = luci.model.uci.cursor()
  local meshvpn_enabled = uci:get("fastd", meshvpn_name, "enabled", "0")
  if meshvpn_enabled == "1" then
    pubkey = configmode.get_fastd_pubkey(meshvpn_name)
  end
  luci.template.render("gluon-config-mode/reboot", {pubkey=pubkey})

  uci:foreach("gluon-config-mode", "wizard", function(s)
      uci:set("gluon-config-mode", s[".name"], "configured", "1")
    end)
  uci:save("gluon-config-mode")
  uci:commit("gluon-config-mode")

  luci.sys.reboot()
end
