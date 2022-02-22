local util = require "gluon.util"
local uci = require("simple-uci").cursor()

local f = Form(translate("Welcome!"))
f.submit = translate('Save & restart')
f.reset = false

local s = f:section(Section)
s.template = "wizard/welcome"
s.package = "gluon-config-mode-core"

for _, entry in ipairs(util.glob('/lib/gluon/config-mode/wizard/*')) do
	local section = assert(loadfile(entry))
	setfenv(section, getfenv())
	section()(f, uci)
end

function f:write()
	local fcntl = require 'posix.fcntl'
	local unistd = require 'posix.unistd'

	uci:set("gluon-setup-mode", uci:get_first("gluon-setup-mode", "setup_mode"), "configured", true)
	uci:save("gluon-setup-mode")

	os.execute('exec gluon-reconfigure >/dev/null')

	f.template = "wizard/reboot"
	f.package = "gluon-config-mode-core"
	f.hidenav = true

	if unistd.fork() == 0 then
		-- Replace stdout with /dev/null
		local null = fcntl.open('/dev/null', fcntl.O_WRONLY)
		unistd.dup2(null, unistd.STDOUT_FILENO)

		-- Sleep a little so the browser can fetch everything required to
		-- display the reboot page, then reboot the device.
		unistd.sleep(1)

		unistd.execp('reboot', {[0] = 'reboot'})
	end
end

return f
