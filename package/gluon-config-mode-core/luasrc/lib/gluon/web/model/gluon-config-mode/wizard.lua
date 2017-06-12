local disp = require 'gluon.web.dispatcher'
local fs = require "nixio.fs"
local util = require "gluon.web.util"
local nixio_util = require "nixio.util"

local uci = require("simple-uci").cursor()

local wizard_dir = "/lib/gluon/config-mode/wizard/"

local files = nixio_util.consume(fs.dir(wizard_dir) or function() end)
table.sort(files)

local wizard = {}
for _, entry in ipairs(files) do
	if entry:sub(1, 1) ~= '.' then
		local f = assert(loadfile(wizard_dir .. entry))
		setfenv(f, getfenv())
		local w = f()
		table.insert(wizard, w)
	end
end

local f = Form(translate("Welcome!"))
f.submit = translate('Save & restart')
f.reset = false

local s = f:section(Section)
s.template = "gluon/config-mode/welcome"

local commit = {'gluon-setup-mode'}

for _, w in ipairs(wizard) do
	for _, c in ipairs(w(f, uci) or {}) do
		if not util.contains(commit, c) then
			table.insert(commit, c)
		end
	end
end

function f:write()
	local nixio = require "nixio"

	uci:set("gluon-setup-mode", uci:get_first("gluon-setup-mode", "setup_mode"), "configured", true)

	for _, c in ipairs(commit) do
		uci:commit(c)
	end

	f.template = "gluon/config-mode/reboot"
	f.hidenav = true

	if nixio.fork() == 0 then
		-- Replace stdout with /dev/null
		nixio.dup(nixio.open('/dev/null', 'w'), nixio.stdout)

		-- Sleep a little so the browser can fetch everything required to
		-- display the reboot page, then reboot the device.
		nixio.nanosleep(1)

		nixio.execp("reboot")
	end
end

return f
