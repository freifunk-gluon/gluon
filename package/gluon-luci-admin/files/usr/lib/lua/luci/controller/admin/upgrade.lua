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
	local has_platform = nixio.fs.access("/lib/upgrade/platform.sh")
	if has_platform then
		entry({"admin", "upgrade"}, call("action_upgrade"), _("Upgrade firmware"), 90)
		entry({"admin", "upgrade", "reboot"}, template("admin/upgrade_reboot"), nil, nil)
	end
end

function action_upgrade()
	local tmpfile = "/tmp/firmware.img"

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
	local step         = tonumber(luci.http.formvalue("step") or 1)
	local has_image    = nixio.fs.access(tmpfile)
	local has_support  = image_supported(tmpfile)

	-- Step 1: file upload, error on unsupported image format
	if not has_image or not has_support or step == 1 then
		-- If there is an image but user has requested step 1
		-- or type is not supported, then remove it.
		if has_image then
			nixio.fs.unlink(tmpfile)
		end

		luci.template.render("admin/upgrade", {
			bad_image=(has_image and not has_support or false)
		} )

	-- Step 2: present uploaded file, show checksum, confirmation
	elseif step == 2 then
		luci.template.render("admin/upgrade_confirm", {
			checksum=image_checksum(tmpfile),
			filesize=nixio.fs.stat(tmpfile).size,
			flashsize=storage_size(),
			keepconfig=luci.http.formvalue("keepcfg") == "1"
		} )
	elseif step == 3 then
		local keepcfg = luci.http.formvalue("keepcfg") == "1"
		fork_exec("/sbin/sysupgrade %s %q" % { keepcfg and "" or "-n", tmpfile })
		luci.http.redirect(luci.dispatcher.build_url("admin", "upgrade", "reboot"))
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

function image_supported(tmpfile)
	-- XXX: yay...
	return ( 0 == os.execute(
		"/sbin/sysupgrade -T %q >/dev/null"
			% tmpfile
	) )
end

function storage_size()
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

function image_checksum(tmpfile)
	return (luci.sys.exec("md5sum %q" % tmpfile):match("^([^%s]+)"))
end
