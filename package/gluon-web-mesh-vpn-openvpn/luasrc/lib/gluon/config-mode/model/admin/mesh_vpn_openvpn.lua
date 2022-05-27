--[[
Copyright 2022 Maciej Krüger <maciej@xeredo.it>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0
]]--

local util = require 'gluon.util'
local unistd = require 'posix.unistd'

local file
local tmpfile = "/tmp/vpninput"

local ssl = require 'openssl'

local vpn_core = require 'gluon.mesh-vpn'
local site = require 'gluon.site'

local function filehandler(_, chunk, eof)
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

-- local function action_upgrade(http, renderer)
-- 	local fcntl = require 'posix.fcntl'
-- 	local stat = require 'posix.sys.stat'

	-- local function fork_exec(argv)
	-- 	local pid = unistd.fork()
	-- 	if pid > 0 then
	-- 		return
	-- 	elseif pid == 0 then
	-- 		-- change to root dir
	-- 		unistd.chdir('/')
	--
	-- 		-- patch stdin, out, err to /dev/null
	-- 		local null = fcntl.open('/dev/null', fcntl.O_RDWR)
	-- 		if null then
	-- 			unistd.dup2(null, unistd.STDIN_FILENO)
	-- 			unistd.dup2(null, unistd.STDOUT_FILENO)
	-- 			unistd.dup2(null, unistd.STDERR_FILENO)
	-- 			if null > 2 then
	-- 				unistd.close(null)
	-- 			end
	-- 		end
	--
	-- 		-- Sleep a little so the browser can fetch everything required to
	-- 		-- display the reboot page, then reboot the device.
	-- 		unistd.sleep(1)
	--
	-- 		-- replace with target command
	-- 		unistd.exec(argv[0], argv)
	-- 	end
	-- end

	-- local function config_supported(supported_tmpfile)
	-- 	return (os.execute(string.format("exec /sbin/sysupgrade -T %q >/dev/null", supported_tmpfile)) == 0)
	-- end
	--
	-- local function storage_size()
	-- 	local size = 0
	-- 	if unistd.access("/proc/mtd") then
	-- 		for l in io.lines("/proc/mtd") do
	-- 			local s, n = l:match('^[^%s]+%s+([^%s]+)%s+[^%s]+%s+"([^%s]+)"')
	-- 			if n == "firmware" then
	-- 				size = tonumber(s, 16)
	-- 				break
	-- 			end
	-- 		end
	-- 	elseif unistd.access("/proc/partitions") then
	-- 		for l in io.lines("/proc/partitions") do
	-- 			local b, n = l:match('^%s*%d+%s+%d+%s+([^%s]+)%s+([^%s]+)')
	-- 			if b and n and not n:match('[0-9]') then
	-- 				size = tonumber(b) * 1024
	-- 				break
	-- 			end
	-- 		end
	-- 	end
	-- 	return size
	-- end
	--
	-- local function config_checksum(checksum_tmpfile)
	-- 	return (util.exec(string.format("exec sha256sum %q", checksum_tmpfile)):match("^([^%s]+)"))
	-- end
--
--
-- 	-- Determine state
-- 	local step = tonumber(http:getenv("REQUEST_METHOD") == "POST" and http:formvalue("step")) or 1
--
-- 	local has_tmp   = unistd.access(tmpfile)
--
-- 	-- Step 1: file upload, error on unsupported config format
-- 	if step == 1 or not has_support then
-- 		-- If there is an config but user has requested step 1
-- 		-- or type is not supported, then remove it.
-- 		if has_config then
-- 			unistd.unlink(tmpfile)
-- 		end
--
-- 		renderer.render_layout('admin/upgrade', {
-- 			bad_config = has_config and not has_support,
-- 		}, 'gluon-web-admin')
--
-- 	-- Step 2: present uploaded file, show checksum, confirmation
-- 	elseif step == 2 then
-- 		renderer.render_layout('admin/upgrade_confirm', {
-- 			checksum   = config_checksum(tmpfile),
-- 			filesize   = stat.stat(tmpfile).st_size,
-- 			flashsize  = storage_size(),
-- 			keepconfig = (http:formvalue("keepcfg") == "1"),
-- 		}, 'gluon-web-admin')
--
-- 	elseif step == 3 then
-- 		local cmd = {[0] = '/sbin/sysupgrade', tmpfile}
-- 		if http:formvalue('keepcfg') ~= '1' then
-- 			table.insert(cmd, 1, '-n')
-- 		end
-- 		fork_exec(cmd)
-- 		renderer.render_layout('admin/upgrade_reboot', nil, 'gluon-web-admin', {
-- 			hidenav = true,
-- 		})
-- 	end
-- end

--

local function translate_format(str, ...)
  return string.format(translate(str), ...)
end

local fcntl = require 'posix.fcntl'
local stat = require 'posix.sys.stat'

local cfg = site.mesh_vpn.openvpn.config()

local f = Form(translate('Mesh VPN'))

local s = f:section(Section)

local function dump_name(name)
	if not name then
		return nil
	end

	local o = {}

	for _, v in ipairs(name:info()) do
		for k, v in pairs(v) do
			o[k] = v
		end
	end

	return o
end

local function try_key(file, input)
  local key = ssl.pkey.read(input, true)

	if not key then
		return
	end

  local info = key:parse()

  return {
    type = 'key',
    display = translate_format('Key %s, %s bits', info.type, info.size * 8),
    info = info,
  }
end

local function try_cert(file, input)
  local cert = ssl.x509.read(input)

	if not cert then
		return cert
	end

  local info = cert:parse()

	local subject = dump_name(info.subject)
  local issuer = dump_name(info.issuer)

  return {
    type = info.ca and 'cacert' or 'cert',
    display = info.ca
			and translate_format('CA Certificate "%s"', subject.CN)
			or translate_format('Certificate "%s" from "%s"', subject.CN, issuer.CN),
    info,
  }
end

local function content_info(file)
  local out = {
    type = nil,
  }

  if file ~= nil and unistd.access(file) then
    local _file = io.open(file, 'rb') -- r read mode and b binary mode

    if _file then
      local input = _file:read '*a' -- *a or *all reads the whole file
      _file:close()

      local status, ret = pcall(try_key, file, input)
      if status and ret then
        return ret
      end

      local status, ret = pcall(try_cert, file, input)
      if status and ret then
        return ret
      end
    end
  end

  return out
end

local function content_info_str(file)
  local info = content_info(file)

  if not info.type then
    return translate('(unknown)')
  end

  return info.display
end

local function file_info(file, desc)
  local i = Info()
  local status

  if unistd.access(file) then
    status = translate_format('Configured, %s', content_info_str(file))
  else
    status = translate('Not configured')
  end

	i:settitle(desc)
  i:setcontent(status)
  s:append(i)
end

local function rename(src, target)
	local f = io.open(src, 'rb')
	local t = io.open(target, 'w')
	local d = f:read('*a')
	t:write(d)
	f:close()
	t:close()
end

local function try_tar(file)
	if os.execute("rm -rf /tmp/_tarex") ~= 0 then
		return
	end
	if os.execute("mkdir -p /tmp/_tarex") ~= 0 then
		return
	end
	if os.execute(string.format("tar xfz %s -C /tmp/_tarex", tmpfile)) ~= 0 then
		return
	end

	-- SECURITY: print0 or something, otherwise exploitation with \n in filename is possible
	local p = io.popen('find /tmp/_tarex -type f')
	for file in p:lines() do
		local info = content_info(file)

		if info.type == 'cacert' and cfg.ca then
	    rename(file, cfg.ca)
	  elseif info.type == 'cert' and cfg.cert then
	    rename(file, cfg.cert)
	  elseif info.type == 'key' and cfg.key then
	    rename(file, cfg.key)
	  elseif info.type == nil then
	    unistd.unlink(file)
	  end

		if info.type then
			local i = Info()
			i:setcontent(translate_format('Successfully installed %s', info.display))
			s:append(i)
		end
	end

	return true
end

if unistd.access(tmpfile) then
  local info = content_info(tmpfile)

  if info.type == 'cacert' and cfg.ca then
    rename(tmpfile, cfg.ca)
  elseif info.type == 'cert' and cfg.cert then
    rename(tmpfile, cfg.cert)
  elseif info.type == 'key' and cfg.key then
    rename(tmpfile, cfg.key)
  elseif info.type == nil then
		if try_tar() then
			info = {
				type = translate('tar configuration'),
				display = '', -- intentionally left empty
			}
		end

    unistd.unlink(tmpfile)
  end

  local i = Info()
  if info.type then
    i:setcontent(translate_format('Successfully installed %s', info.display))
  else
    i:setcontent(translate_format('Error: Unknown file'))
  end
  s:append(i)
end

if cfg.ca then
	file_info(cfg.ca, translate('CA Cert'))
end
if cfg.cert then
	file_info(cfg.cert, translate('Mesh Cert'))
end
if cfg.key then
	file_info(cfg.key, translate('Mesh Key'))
end

local c = File()
c.title = translate('Upload .tar.gz, key, CA or cert')
s:append(c)

return f
