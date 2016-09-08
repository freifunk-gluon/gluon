--[[
Copyright 2013 Nils Schneider <nils@nilsschneider.net>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--

module("luci.controller.gluon-config-mode.index", package.seeall)

function index()
  local uci_state = luci.model.uci.cursor_state()

  if uci_state:get_first("gluon-setup-mode", "setup_mode", "running", "0") == "1" then
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
  local uci = luci.model.uci.cursor()

  uci:set("gluon-setup-mode", uci:get_first("gluon-setup-mode", "setup_mode"), "configured", "1")
  uci:save("gluon-setup-mode")
  uci:commit("gluon-setup-mode")

  local gluon_luci = require "gluon.luci"
  local fs = require "nixio.fs"
  local util = require "nixio.util"
  local pretty_hostname = require "pretty_hostname"

  local parts_dir = "/lib/gluon/config-mode/reboot/"
  local files = util.consume(fs.dir(parts_dir))

  table.sort(files)

  local parts = {}

  for _, entry in ipairs(files) do
    if entry:sub(1, 1) ~= '.' then
      local f = dofile(parts_dir .. '/' .. entry)
      if f ~= nil then
        table.insert(parts, f)
      end
    end
  end

  local hostname = pretty_hostname.get(uci)

  luci.template.render("gluon/config-mode/reboot",
    {
      parts = parts,
      hostname = hostname,
      escape = gluon_luci.escape,
      urlescape = gluon_luci.urlescape,
    }
  )

  if nixio.fork() == 0 then
    -- Replace stdout with /dev/null
    nixio.dup(nixio.open('/dev/null', 'w'), nixio.stdout)

    -- Sleep a little so the browser can fetch everything required to
    -- display the reboot page, then reboot the device.
    nixio.nanosleep(1)

    nixio.execp("reboot")
  end
end
