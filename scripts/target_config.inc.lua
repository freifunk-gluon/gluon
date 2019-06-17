assert(env.BOARD)
assert(env.SUBTARGET)


local target = arg[1]
local extra_packages = arg[2]

local openwrt_config_target
if env.SUBTARGET ~= '' then
	openwrt_config_target = env.BOARD .. '_' .. env.SUBTARGET
else
	openwrt_config_target = env.BOARD
end


local function site_packages(profile)
	return exec_capture_raw(string.format([[
	MAKEFLAGS= make print PROFILE=%s --no-print-directory -s -f - <<'END_MAKE'
include $(GLUON_SITEDIR)/site.mk

print:
	echo -n '$(GLUON_$(PROFILE)_SITE_PACKAGES)'
END_MAKE
	]], escape(profile)))
end

dofile(env.GLUON_TARGETSDIR .. '/generic')
for pkg in string.gmatch(extra_packages, '%S+') do
	packages {pkg}
end
dofile(env.GLUON_TARGETSDIR .. '/' .. target)

check_devices()


if not opkg then
	config '# CONFIG_SIGNED_PACKAGES is not set'
	config 'CONFIG_CLEAN_IPKG=y'
	packages {'-opkg'}
end


local default_pkgs = ''
for _, pkg in ipairs(target_packages) do
	default_pkgs = default_pkgs .. ' ' .. pkg

	if string.sub(pkg, 1, 1) == '-' then
		try_config('# CONFIG_PACKAGE_%s is not set', string.sub(pkg, 2))
	else
		config_package(pkg, 'y')
	end
end

for _, dev in ipairs(devices) do
	local profile = dev.options.profile or dev.name
	local device_pkgs = default_pkgs

	local function handle_pkg(pkg)
		if string.sub(pkg, 1, 1) ~= '-' then
			config_package(pkg, 'm')
		end
		device_pkgs = device_pkgs .. ' ' .. pkg
	end

	for _, pkg in ipairs(dev.options.packages or {}) do
		handle_pkg(pkg)
	end
	for pkg in string.gmatch(site_packages(profile), '%S+') do
		handle_pkg(pkg)
	end

	config_message(string.format("unable to enable device '%s'", profile),
		'CONFIG_TARGET_DEVICE_%s_DEVICE_%s=y', openwrt_config_target, profile)
	config('CONFIG_TARGET_DEVICE_PACKAGES_%s_DEVICE_%s="%s"',
		openwrt_config_target, profile, device_pkgs)
end
