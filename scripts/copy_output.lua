local lib = dofile('scripts/target_lib.lua')
local env = lib.env

assert(env.GLUON_IMAGEDIR)
assert(env.GLUON_PACKAGEDIR)


local target = arg[1]

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


lib.include(target)


local function clean(image, name)
	local dir, file = image:dest_name(name, '\0', '\0')
	lib.exec {'rm', '-f', dir..'/'..file}
end

for _, images in pairs(lib.images) do
	for _, image in ipairs(images) do
		clean(image, image.image)

		local destdir, destname = image:dest_name(image.image)
		local source = string.format('openwrt/bin/targets/%s/openwrt-%s-%s%s%s',
			bindir, openwrt_target, image.name, image.in_suffix, image.extension)

		lib.exec {'cp', source, destdir..'/'..destname}

		for _, alias in ipairs(image.aliases) do
			clean(image, alias)

			local _, aliasname = image:dest_name(alias)
			lib.exec {'ln', '-s', destname, destdir..'/'..aliasname}
		end
	end
end


-- Copy opkg repo
if lib.opkg and (env.GLUON_DEVICES or '') == '' then
	local package_prefix = string.format('gluon-%s-%s', lib.site_code, env.GLUON_RELEASE)
	local function dest_dir(prefix)
		return env.GLUON_PACKAGEDIR..'/'..prefix..'/'..bindir
	end

	lib.exec {'rm', '-f', dest_dir('\0')..'/\0'}
	lib.exec({'rmdir', '-p', dest_dir('\0')}, true, '2>/dev/null')
	mkdir(dest_dir(package_prefix))
	lib.exec {'cp', 'openwrt/bin/targets/'..bindir..'/packages/\0', dest_dir(package_prefix)}
end
