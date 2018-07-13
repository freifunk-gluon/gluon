--[[
Copyright 2008 Steven Barth <steven@midlink.org>
Copyright 2008 Jo-Philipp Wich <xm@leipzig.freifunk.net>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0
]]--

package 'gluon-web-admin'


local util = require 'gluon.util'
local unistd = require 'posix.unistd'

local tmpfile = "/tmp/firmware.img"


local function filehandler(meta, chunk, eof)
	if not unistd.access(tmpfile) and not file and chunk and #chunk > 0 then
		file = io.open(tmpfile, "w")
	end
	if file and chunk then
		file:write(chunk)
	end
	if file and eof then
		file:close()
	end
end

local function action_upgrade(http, renderer)
	local fcntl = require 'posix.fcntl'
	local stat = require 'posix.sys.stat'
	local wait = require 'posix.sys.wait'

	local function fork_exec(argv)
		local pid = unistd.fork()
		if pid > 0 then
			return
		elseif pid == 0 then
			-- change to root dir
			unistd.chdir('/')

			-- patch stdin, out, err to /dev/null
			local null = fcntl.open('/dev/null', fcntl.O_RDWR)
			if null then
				unistd.dup2(null, unistd.STDIN_FILENO)
				unistd.dup2(null, unistd.STDOUT_FILENO)
				unistd.dup2(null, unistd.STDERR_FILENO)
				if null > 2 then
					unistd.close(null)
				end
			end

			-- Sleep a little so the browser can fetch everything required to
			-- display the reboot page, then reboot the device.
			unistd.sleep(1)

			-- replace with target command
			unistd.exec(argv[0], argv)
		end
	end

	local function image_supported(tmpfile)
		return (os.execute(string.format("exec /sbin/sysupgrade -T %q >/dev/null", tmpfile)) == 0)
	end

	local function storage_size()
		local size = 0
		if unistd.access("/proc/mtd") then
			for l in io.lines("/proc/mtd") do
				local d, s, e, n = l:match('^([^%s]+)%s+([^%s]+)%s+([^%s]+)%s+"([^%s]+)"')
				if n == "linux" then
					size = tonumber(s, 16)
					break
				end
			end
		elseif unistd.access("/proc/partitions") then
			for l in io.lines("/proc/partitions") do
				local x, y, b, n = l:match('^%s*(%d+)%s+(%d+)%s+([^%s]+)%s+([^%s]+)')
				if b and n and not n:match('[0-9]') then
					size = tonumber(b) * 1024
					break
				end
			end
		end
		return size
	end

	local function image_checksum(tmpfile)
		return (util.exec(string.format("exec sha256sum %q", tmpfile)):match("^([^%s]+)"))
	end


	-- Determine state
	local step = tonumber(http:getenv("REQUEST_METHOD") == "POST" and http:formvalue("step")) or 1

	local has_image   = unistd.access(tmpfile)
	local has_support = has_image and image_supported(tmpfile)

	-- Step 1: file upload, error on unsupported image format
	if step == 1 or not has_support then
		-- If there is an image but user has requested step 1
		-- or type is not supported, then remove it.
		if has_image then
			unistd.unlink(tmpfile)
		end

		renderer.render_layout('admin/upgrade', {
			bad_image = has_image and not has_support,
		}, 'gluon-web-admin')

	-- Step 2: present uploaded file, show checksum, confirmation
	elseif step == 2 then
		renderer.render_layout('admin/upgrade_confirm', {
			checksum   = image_checksum(tmpfile),
			filesize   = stat.stat(tmpfile).st_size,
			flashsize  = storage_size(),
			keepconfig = (http:formvalue("keepcfg") == "1"),
		}, 'gluon-web-admin')

	elseif step == 3 then
		local cmd = {[0] = '/sbin/sysupgrade', tmpfile}
		if http:formvalue('keepcfg') ~= '1' then
			table.insert(cmd, 1, '-n')
		end
		fork_exec(cmd)
		renderer.render_layout('admin/upgrade_reboot', nil, 'gluon-web-admin', {
			hidenav = true,
		})
	end
end


local has_platform = unistd.access("/lib/upgrade/platform.sh")
if has_platform then
	local upgrade = entry({"admin", "upgrade"}, call(action_upgrade), _("Upgrade firmware"), 90)
	upgrade.filehandler = filehandler
end
