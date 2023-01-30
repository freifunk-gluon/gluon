local lib = dofile('scripts/target_lib.lua')
local env = lib.env

local target = env.GLUON_TARGET

assert(target)
assert(env.GLUON_IMAGEDIR)
assert(env.GLUON_PACKAGEDIR)


local openwrt_target
local subtarget = env.SUBTARGET
if subtarget ~= '' then
	openwrt_target = env.BOARD .. '-' .. subtarget
else
	openwrt_target = env.BOARD
	subtarget = 'generic'
end

local bindir = env.BOARD .. '/' .. subtarget


local function mkdir(dir)
	lib.exec {'mkdir', '-p', dir}
end

mkdir(env.GLUON_IMAGEDIR..'/factory')
mkdir(env.GLUON_IMAGEDIR..'/sysupgrade')
mkdir(env.GLUON_IMAGEDIR..'/other')
mkdir(env.GLUON_DEBUGDIR)


lib.include(target)


local function image_source(image)
	return string.format(
		'openwrt/bin/targets/%s/' .. (env.GLUON_PREFIX or 'openwrt') .. '-%s-%s%s%s',
		bindir, openwrt_target, image.name, image.in_suffix, image.extension)
end

local function clean(image, name)
	local dir, file = image:dest_name(name, '\0', '\0')
	lib.exec {'rm', '-f', dir..'/'..file}
end

for _, images in pairs(lib.images) do
	for _, image in ipairs(images) do
		clean(image, image.image)

		local destdir, destname = image:dest_name(image.image)
		local source = image_source(image)

		lib.exec {'cp', source, destdir..'/'..destname}

		for _, alias in ipairs(image.aliases) do
			clean(image, alias)

			local _, aliasname = image:dest_name(alias)
			lib.exec {'ln', '-s', destname, destdir..'/'..aliasname}
		end
	end

	for _, image in ipairs(images) do
		local source = image_source(image)
		lib.exec {'rm', '-f', source}
	end
end

-- copy kernel image with debug symbols
local kernel_debug_glob = string.format('%s/gluon-\0-%s-kernel-debug.tar.zst',
	env.GLUON_DEBUGDIR,
	target)
lib.exec {'rm', '-f', kernel_debug_glob}
local kernel_debug_source = string.format('openwrt/bin/targets/%s/kernel-debug.tar.zst',
	bindir)
local kernel_debug_dest = string.format('%s/gluon-%s-%s-%s-kernel-debug.tar.zst',
	env.GLUON_DEBUGDIR,
	lib.site_code,
	env.GLUON_RELEASE,
	target)
lib.exec {'cp', kernel_debug_source, kernel_debug_dest}


-- Copy opkg repo
if (env.GLUON_DEVICES or '') == '' then
	local package_prefix = string.format('gluon-%s-%s', lib.site_code, env.GLUON_RELEASE)
	local function dest_dir(prefix)
		return env.GLUON_PACKAGEDIR..'/'..prefix..'/'..bindir
	end

	lib.exec {'rm', '-f', dest_dir('\0')..'/\0'}
	lib.exec({'rmdir', '-p', dest_dir('\0')}, true, '2>/dev/null')
	mkdir(dest_dir(package_prefix))
	lib.exec {'cp', 'openwrt/bin/targets/'..bindir..'/packages/\0', dest_dir(package_prefix)}
end
