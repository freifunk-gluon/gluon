--[[
Copyright 2008 Steven Barth <steven@midlink.org>
Copyright 2008 Jo-Philipp Wich <xm@leipzig.freifunk.net>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0
]]--

local fs = require 'nixio.fs'

local tmpfile = "/tmp/firmware.img"


local function filehandler(meta, chunk, eof)
	if not fs.access(tmpfile) and not file and chunk and #chunk > 0 then
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
	local disp = require 'gluon.web.dispatcher'
	local nixio = require 'nixio'

	local function fork_exec(...)
		local pid = nixio.fork()
		if pid > 0 then
			return
		elseif pid == 0 then
			-- change to root dir
			nixio.chdir("/")

			-- patch stdin, out, err to /dev/null
			local null = nixio.open("/dev/null", "w+")
			if null then
				nixio.dup(null, nixio.stderr)
				nixio.dup(null, nixio.stdout)
				nixio.dup(null, nixio.stdin)
				if null:fileno() > 2 then
					null:close()
				end
			end

			-- Sleep a little so the browser can fetch everything required to
			-- display the reboot page, then reboot the device.
			nixio.nanosleep(1)

			-- replace with target command
			nixio.exec(...)
		end
	end

	local function image_supported(tmpfile)
		-- XXX: yay...
		return (os.execute(string.format("/sbin/sysupgrade -T %q >/dev/null", tmpfile)) == 0)
	end

	local function storage_size()
		local size = 0
		if fs.access("/proc/mtd") then
			for l in io.lines("/proc/mtd") do
				local d, s, e, n = l:match('^([^%s]+)%s+([^%s]+)%s+([^%s]+)%s+"([^%s]+)"')
				if n == "linux" then
					size = tonumber(s, 16)
					break
				end
			end
		elseif fs.access("/proc/partitions") then
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
		return (gluon.web.util.exec(string.format("md5sum %q", tmpfile)):match("^([^%s]+)"))
	end


	-- Determine state
	local step = tonumber(http:getenv("REQUEST_METHOD") == "POST" and http:formvalue("step")) or 1

	local has_image   = fs.access(tmpfile)
	local has_support = has_image and image_supported(tmpfile)

	-- Step 1: file upload, error on unsupported image format
	if step == 1 or not has_support then
		-- If there is an image but user has requested step 1
		-- or type is not supported, then remove it.
		if has_image then
			fs.unlink(tmpfile)
		end

		renderer.render("layout", {
			content = "admin/upgrade",
			bad_image = has_image and not has_support,
		})

	-- Step 2: present uploaded file, show checksum, confirmation
	elseif step == 2 then
		renderer.render("layout", {
			content = "admin/upgrade_confirm",
			checksum   = image_checksum(tmpfile),
			filesize   = fs.stat(tmpfile).size,
			flashsize  = storage_size(),
			keepconfig = (http:formvalue("keepcfg") == "1"),
		})
	elseif step == 3 then
		if http:formvalue("keepcfg") == "1" then
			fork_exec("/sbin/sysupgrade", tmpfile)
		else
			fork_exec("/sbin/sysupgrade", "-n", tmpfile)
		end
		renderer.render("layout", {
			content = "admin/upgrade_reboot",
			hidenav = true,
		})
	end
end


local has_platform = fs.access("/lib/upgrade/platform.sh")
if has_platform then
	local upgrade = entry({"admin", "upgrade"}, call(action_upgrade), _("Upgrade firmware"), 90)
	upgrade.filehandler = filehandler
end
