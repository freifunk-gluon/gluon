local lib = dofile('scripts/target_lib.lua')
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

local function compact_list(list, keep_neg)
	local ret = {}
	for _, el in ipairs(list) do
		ret  = append_to_list(ret, el, keep_neg)
	end
	return ret
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

-- TODO: Rewrite features.sh in Lua
local function feature_packages(features)
	-- Ugly hack: Lua doesn't give us the return code of a popened
	-- command, so we match on a special __ERROR__ marker
	local pkgs = lib.exec_capture({'scripts/features.sh', features}, '|| echo __ERROR__')
	assert(string.find(pkgs, '__ERROR__') == nil, 'Error while evaluating features')
	return pkgs
end

-- This involves running lots of processes to evaluate site.mk, so we
-- add a simple cache
local class_cache = {}
local function class_packages(class)
	if class_cache[class] then
		return class_cache[class]
	end

	local features = site_vars(string.format('$(GLUON_FEATURES) $(GLUON_FEATURES_%s)', class))
	features = table.concat(compact_list(split(features), false), ' ')

	local pkgs = feature_packages(features)
	pkgs = pkgs .. ' ' .. site_vars(string.format('$(GLUON_SITE_PACKAGES) $(GLUON_SITE_PACKAGES_%s)', class))

	pkgs = compact_list(split(pkgs))

	class_cache[class] = pkgs
	return pkgs
end

local enabled_packages = {}
-- Arguments: package name and config value (true: y, nil: m, false: unset)
-- Ensures precedence of y > m > unset
local function config_package(pkg, v)
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

lib.include('generic')
lib.include(target)

lib.check_devices()

if not lib.opkg then
	lib.config('SIGNED_PACKAGES', false)
	lib.config('CLEAN_IPKG', true)
	lib.config('ALL_NONSHARED', false)
	lib.packages {'-opkg'}
end

if #lib.devices > 0 then
	handle_target_pkgs(lib.target_packages)

	for _, dev in ipairs(lib.devices) do
		local profile = dev.options.profile or dev.name

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
		handle_pkgs(class_packages(dev.options.class))
		handle_pkgs(dev.options.packages or {})
		handle_pkgs(site_packages(dev.image))

		local profile_config = string.format('%s_DEVICE_%s', openwrt_config_target, profile)
		lib.config(
			'TARGET_DEVICE_' .. profile_config, true,
			string.format("unable to enable device '%s'", profile)
		)
		lib.config(
			'TARGET_DEVICE_PACKAGES_' .. profile_config,
			table.concat(device_pkgs, ' ')
		)
	end
else
	-- x86 fallback: no devices
	local target_pkgs = {}
	local function handle_pkgs(pkgs)
		for _, pkg in ipairs(pkgs) do
			target_pkgs = append_to_list(target_pkgs, pkg)
		end
	end

	-- Just hardcode the class for device-less targets to 'standard'
	-- - this is x86 only at the moment, and it will have devices
	-- in OpenWrt 19.07 + 1 as well
	handle_pkgs(lib.target_packages)
	handle_pkgs(class_packages('standard'))

	handle_target_pkgs(target_pkgs)
end

return lib
