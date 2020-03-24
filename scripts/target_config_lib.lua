return function(funcs)
	local lib = dofile('scripts/target_lib.lua')
	local env = lib.env

	assert(env.BOARD)
	assert(env.SUBTARGET)

	local target = arg[1]
	local extra_packages = arg[2]
	local class_packages = {
		standard = arg[3],
		tiny = arg[4],
	}

	local openwrt_config_target
	if env.SUBTARGET ~= '' then
		openwrt_config_target = env.BOARD .. '_' .. env.SUBTARGET
	else
		openwrt_config_target = env.BOARD
	end


	local function site_packages(image)
		return lib.exec_capture_raw(string.format([[
	MAKEFLAGS= make print _GLUON_IMAGE_=%s --no-print-directory -s -f - <<'END_MAKE'
include $(GLUON_SITEDIR)/site.mk

print:
	echo -n '$(GLUON_$(_GLUON_IMAGE_)_SITE_PACKAGES)'
END_MAKE
		]], lib.escape(image)))
	end

	lib.include('generic')
	for pkg in string.gmatch(extra_packages, '%S+') do
		lib.packages {pkg}
	end
	lib.include(target)

	lib.check_devices()


	if not lib.opkg then
		lib.config '# CONFIG_SIGNED_PACKAGES is not set'
		lib.config 'CONFIG_CLEAN_IPKG=y'
		lib.packages {'-opkg'}
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

	for _, dev in ipairs(lib.devices) do
		local profile = dev.options.profile or dev.name
		local device_pkgs = default_pkgs

		local function handle_pkg(pkg)
			if string.sub(pkg, 1, 1) ~= '-' then
				funcs.config_package(lib.config, pkg, 'm')
			end
			device_pkgs = device_pkgs .. ' ' .. pkg
		end
		local function handle_pkgs(pkgs)
			local packages = string.gmatch(pkgs or '', '%S+')
			for pkg in packages do
				handle_pkg(pkg)
			end
		end

		for _, pkg in ipairs(dev.options.packages or {}) do
			handle_pkg(pkg)
		end
		handle_pkgs(site_packages(dev.image))

		handle_pkgs(class_packages[dev.options.class])

		funcs.config_message(lib.config, string.format("unable to enable device '%s'", profile),
			'CONFIG_TARGET_DEVICE_%s_DEVICE_%s=y', openwrt_config_target, profile)
		lib.config('CONFIG_TARGET_DEVICE_PACKAGES_%s_DEVICE_%s="%s"',
			openwrt_config_target, profile, device_pkgs)
	end

	return lib
end
