local lib = dofile('scripts/target_lib.lua')
local env = lib.env


local subtarget = env.SUBTARGET
if subtarget == '' then
	subtarget = 'generic'
end

local bindir = env.BOARD .. '/' .. subtarget


lib.exec({'rm', '-f', 'openwrt/bin/targets/'..bindir..'/\0'}, true, '2>/dev/null')

-- Full builds will output the "packages" directory, so clean up first
if (env.GLUON_DEVICES or '') == '' then
	lib.exec {'rm', '-rf', 'openwrt/bin/targets/'..bindir..'/packages'}
end
