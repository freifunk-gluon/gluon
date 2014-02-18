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

module("luci.controller.admin.upgrade", package.seeall)

function index()
	entry({"admin", "upgrade"}, call("action_upgrade"), "Firmware aktualisieren", 90)
end

function action_upgrade()
	require("luci.model.uci")

	local tmpfile = "/tmp/firmware.img"

	local function image_supported()
		-- XXX: yay...
		return ( 0 == os.execute(
			". /lib/functions.sh; " ..
			"include /lib/upgrade; " ..
			"platform_check_image %q >/dev/null"
				% tmpfile
		) )
	end

	local function image_checksum()
		return (luci.sys.exec("md5sum %q" % tmpfile):match("^([^%s]+)"))
	end

	local function storage_size()
		local size = 0
		if nixio.fs.access("/proc/mtd") then
			for l in io.lines("/proc/mtd") do
				local d, s, e, n = l:match('^([^%s]+)%s+([^%s]+)%s+([^%s]+)%s+"([^%s]+)"')
				if n == "linux" then
					size = tonumber(s, 16)
					break
				end
			end
		elseif nixio.fs.access("/proc/partitions") then
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


	-- Install upload handler
	local file
	luci.http.setfilehandler(
		function(meta, chunk, eof)
			if not nixio.fs.access(tmpfile) and not file and chunk and #chunk > 0 then
				file = io.open(tmpfile, "w")
			end
			if file and chunk then
				file:write(chunk)
			end
			if file and eof then
				file:close()
			end
		end
	)


	-- Determine state
	local keep_avail   = true
	local step         = tonumber(luci.http.formvalue("step") or 1)
	local has_image    = nixio.fs.access(tmpfile)
	local has_support  = image_supported()
	local has_platform = nixio.fs.access("/lib/upgrade/platform.sh")
	local has_upload   = luci.http.formvalue("image")

	--
	-- This is step 1-3, which does the user interaction and
	-- image upload.
	--

	-- Step 1: file upload, error on unsupported image format
	if not has_image or not has_support or step == 1 then
		-- If there is an image but user has requested step 1
		-- or type is not supported, then remove it.
		if has_image then
			nixio.fs.unlink(tmpfile)
		end

		luci.template.render("admin/upgrade", {
			step=1,
			bad_image=(has_image and not has_support or false),
			keepavail=keep_avail,
			supported=has_platform
		} )

	-- Step 2: present uploaded file, show checksum, confirmation
	elseif step == 2 then
		luci.template.render("admin/upgrade", {
			step=2,
			checksum=image_checksum(),
			filesize=nixio.fs.stat(tmpfile).size,
			flashsize=storage_size(),
			keepconfig=(keep_avail and luci.http.formvalue("keepcfg") == "1")
		} )

	-- Step 3: load iframe which calls the actual flash procedure
	elseif step == 3 then
		-- invoke sysupgrade
		local keepcfg = keep_avail and luci.http.formvalue("keepcfg") == "1"
		fork_exec("/sbin/sysupgrade %s %q" %
				{ keepcfg and "" or "-n"
				, tmpfile
				}
			)

		luci.template.render("admin/upgrade", { step=3 } )
	end
end

function fork_exec(command)
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

		-- replace with target command
		nixio.exec("/bin/sh", "-c", command)
	end
end
