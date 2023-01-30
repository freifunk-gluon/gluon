local lib = dofile('scripts/target_lib.lua')
local feature_lib = dofile('scripts/feature_lib.lua')
local env = lib.env

local target = env.GLUON_TARGET

assert(target)
assert(env.BOARD)
assert(env.SUBTARGET)

local openwrt_config_target
if env.SUBTARGET ~= '' then
	openwrt_config_target = env.BOARD .. '_' .. env.SUBTARGET
else
	openwrt_config_target = env.BOARD
end


-- Split a string into words
local function split(s)
	local ret = {}
	for w in string.gmatch(s, '%S+') do
		table.insert(ret, w)
	end
	return ret
end

local feeds = split(lib.exec_capture_raw('. scripts/modules.sh; echo "$FEEDS"'))

-- Strip leading '-' character
local function strip_neg(s)
	if string.sub(s, 1, 1) == '-' then
		return string.sub(s, 2)
	else
		return s
	end
end

-- Add an element to a list, removing duplicate entries and handling negative
-- elements prefixed with a '-'
local function append_to_list(list, item, keep_neg)
	local match = strip_neg(item)
	local ret = {}
	for _, el in ipairs(list) do
		if strip_neg(el) ~= match then
			table.insert(ret, el)
		end
	end
	if keep_neg ~= false or string.sub(item, 1, 1) ~= '-' then
		table.insert(ret, item)
	end
	return ret
end

local function concat_list(a, b, keep_neg)
	local ret = a
	for _, el in ipairs(b) do
		ret  = append_to_list(ret, el, keep_neg)
	end
	return ret
end

local function compact_list(list, keep_neg)
	return concat_list({}, list, keep_neg)
end

local function file_exists(file)
	local f = io.open(file)
	if not f then
		return false
	end
	f:close()
	return true
end

local function site_vars(var)
	return lib.exec_capture_raw(string.format(
[[
MAKEFLAGS= make print _GLUON_SITE_VARS_=%s --no-print-directory -s -f - <<'END_MAKE'
include $(GLUON_SITEDIR)/site.mk

print:
	echo -n '$(_GLUON_SITE_VARS_)'
END_MAKE
]],
	lib.escape(var)))
end

local function site_packages(image)
	return split(site_vars(string.format('$(GLUON_%s_SITE_PACKAGES)', image)))
end

local function feature_packages(features)
	local files = {'package/features'}
	for _, feed in ipairs(feeds) do
		local path = string.format('packages/%s/features', feed)
		if file_exists(path) then
			table.insert(files, path)
		end
	end

	return feature_lib.get_packages(files, features)
end

-- This involves running a few processes to evaluate site.mk, so we add a simple cache
local class_cache = {}
local function class_packages(class)
	if class_cache[class] then
		return class_cache[class]
	end

	local features = site_vars(string.format('$(GLUON_FEATURES) $(GLUON_FEATURES_%s)', class))
	features = compact_list(split(features), false)

	local pkgs = feature_packages(features)
	pkgs = concat_list(pkgs, split(site_vars(string.format('$(GLUON_SITE_PACKAGES) $(GLUON_SITE_PACKAGES_%s)', class))))

	class_cache[class] = pkgs
	return pkgs
end

local enabled_packages = {}
-- Arguments: package name and config value (true: y, nil: m, false: unset)
-- Ensures precedence of y > m > unset
local function config_package(pkg, v)
	-- HACK: Handle virtual default packages
	local subst = {
		nftables = 'nftables-nojson'
	}
	if subst[pkg] then
		pkg = subst[pkg]
	end

	if v == false then
		if not enabled_packages[pkg] then
			lib.try_config('PACKAGE_' .. pkg, false)
		end
		return
	end

	if v == true or not enabled_packages[pkg] then
		lib.config('PACKAGE_' .. pkg, v, string.format("unable to enable package '%s'", pkg))
		enabled_packages[pkg] = true
	end
end

local function handle_target_pkgs(pkgs)
	for _, pkg in ipairs(pkgs) do
		if string.sub(pkg, 1, 1) == '-' then
			config_package(string.sub(pkg, 2), false)
		else
			config_package(pkg, true)
		end
	end
end

local function get_default_pkgs()
	local targetinfo_target = string.gsub(openwrt_config_target, '_', '/')
	local target_matches = false
	for line in io.lines('openwrt/tmp/.targetinfo') do
		local target_match = string.match(line, '^Target: (.+)$')
		if target_match then
			target_matches = (target_match == targetinfo_target)
		end

		local default_packages_match = string.match(line, '^Default%-Packages: (.+)$')
		if target_matches and default_packages_match then
			return split(default_packages_match)
		end
	end

	io.stderr:write('Error: unable to get default packages for OpenWrt target ', targetinfo_target, '\n')
	os.exit(1)
end

lib.include('generic')
lib.include('generic_' .. env.GLUON_BUILDTYPE)
lib.include(target)

lib.check_devices()

handle_target_pkgs(concat_list(get_default_pkgs(), lib.target_packages))

-- the if condition in ipairs checks if a user-configured target is
-- trying to build all devices, in which case specific gluon target-definitions are skipped
for _, dev in ipairs(lib.configs.TARGET_ALL_PROFILES and {} or lib.devices) do
	local device_pkgs = {}
	local function handle_pkgs(pkgs)
		for _, pkg in ipairs(pkgs) do
			if string.sub(pkg, 1, 1) ~= '-' then
				config_package(pkg, nil)
			end
			device_pkgs = append_to_list(device_pkgs, pkg)
		end
	end

	handle_pkgs(lib.target_packages)
	handle_pkgs(dev.options.packages or {})

	if env.GLUON_BUILDTYPE == 'gluon' then
		handle_pkgs(class_packages(dev.options.class))
		handle_pkgs(site_packages(dev.image))
	else
		handle_pkgs(lib.target_class_packages[dev.options.class] or {})
	end

	local profile_config = string.format('%s_DEVICE_%s', openwrt_config_target, dev.name)
	lib.config(
		'TARGET_DEVICE_' .. profile_config, true,
		string.format("unable to enable device '%s'", dev.name)
	)
	lib.config(
		'TARGET_DEVICE_PACKAGES_' .. profile_config,
		table.concat(device_pkgs, ' ')
	)
end

return lib
