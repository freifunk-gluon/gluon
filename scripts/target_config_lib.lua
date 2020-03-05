return function(funcs)
	local lib = dofile('scripts/target_lib.lua')
	local env = lib.env

	assert(env.BOARD)
	assert(env.SUBTARGET)

	local target = arg[1]
	local default_packages = arg[2]
	local extra_packages = arg[3] or ""

	local openwrt_config_target
	if env.SUBTARGET ~= '' then
		openwrt_config_target = env.BOARD .. '_' .. env.SUBTARGET
	else
		openwrt_config_target = env.BOARD
	end


	local function site_packages(image)
		io.stderr:write("site_packages(".. image ..")\n")
		return lib.exec_capture_raw(string.format([[
	MAKEFLAGS= make print _GLUON_IMAGE_=%s --no-print-directory -s -f - <<'END_MAKE'
include $(GLUON_SITEDIR)/site.mk

print:
	echo -n '$(GLUON_$(_GLUON_IMAGE_)_SITE_PACKAGES)'
END_MAKE
		]], lib.escape(image)))
	end

	lib.include('generic')
	lib.include('generic_' .. env.FOREIGN_BUILD)
	io.stderr:write(string.format("target_config_lib.lua:default_packages is: %s\n", default_packages))
	for pkg in string.gmatch(default_packages, '%S+') do
		lib.packages {pkg}
	end
	io.stderr:write(string.format("target_config_lib.lua: calling lib.include(target)\n"))
	lib.include(target)

	io.stderr:write(string.format("target_config_lib.lua: calling lib.check_devices()\n"))
	lib.check_devices()


	if not lib.opkg then
		lib.config '# CONFIG_SIGNED_PACKAGES is not set'
		lib.config 'CONFIG_CLEAN_IPKG=y'
		lib.packages {'-opkg'}
	end

	io.stderr:write(string.format("target_config_lib.lua: calling starting loop extra_packages\n"))
	for pkg in string.gmatch(extra_packages, '%S+') do
		lib.e_packages {pkg}
	end


	local default_pkgs = ''
	for _, pkg in ipairs(lib.target_packages) do
		default_pkgs = default_pkgs .. ' ' .. pkg

		if string.sub(pkg, 1, 1) == '-' then
			lib.try_config('# CONFIG_PACKAGE_%s is not set', string.sub(pkg, 2))
		else
			funcs.config_package(lib.config, pkg, 'y')
		end
	end

	local function devpkgs(dev)
		io.stderr:write(string.format("called target_config_lib.lua:devpkgs(%s)\n", dev.name))
		local device_pkgs = default_pkgs

		for _, pkg in ipairs(dev.options.packages or {}) do
			device_pkgs = device_pkgs .. ' ' .. pkg
		end
		for pkg in string.gmatch(site_packages(dev.image), '%S+') do
			device_pkgs = device_pkgs .. ' ' .. pkg
		end

io.stderr:write(string.format("debug_a: %s\n", device_pkgs))
		return(device_pkgs)
	end

	for _, dev in ipairs(lib.devices) do
		local profile = dev.options.profile or dev.name
		local device_pkgs = devpkgs(dev)

io.stderr:write(string.format("debug: %s\n", device_pkgs))

		local function handle_pkg(pkg)
			if string.sub(pkg, 1, 1) ~= '-' then
				funcs.config_package(lib.config, pkg, 'm')
			end
			device_pkgs = device_pkgs .. ' ' .. pkg
		end

		io.stderr:write("debug: in for _, dev in ipairs(lib.devices) for profile " .. profile .. "\n")

		for pkg in string.gmatch(device_pkgs, '%S+') do
			handle_pkg(pkg)
		end

		funcs.config_message(lib.config, string.format("unable to enable device '%s'", profile),
			'CONFIG_TARGET_DEVICE_%s_DEVICE_%s=y', openwrt_config_target, profile)
		lib.config('CONFIG_TARGET_DEVICE_PACKAGES_%s_DEVICE_%s="%s"',
			openwrt_config_target, profile, device_pkgs)

	end

	local extra_pkgs = ''
	for _, pkg in ipairs(lib.extra_packages) do
		extra_pkgs = extra_pkgs .. ' ' .. pkg
		funcs.config_package(lib.config_m, pkg, "m")
	end

	function get_pkglist()
		local adevice_pkgs = {}
		io.stderr:write(string.format("called target_config_lib.lua:get_pkglist()\n"))
		for _, dev in ipairs(lib.devices) do
			local profile = dev.options.profile or dev.name
			local pkgs = devpkgs(dev)
			io.stderr:write(string.format("get_pkglist().profile: %s\n", profile))
			io.stderr:write(string.format("get_pkglist().pkgs: %s\n", pkgs))
			table.insert(adevice_pkgs, {profile, pkgs})
			io.stderr:write(string.format("get_pkglist().length: %i\n", #adevice_pkgs))
		end
		io.stderr:write(string.format("get_pkglist().length_final: %i\n", #adevice_pkgs))
		return adevice_pkgs
	end

	return lib
end
