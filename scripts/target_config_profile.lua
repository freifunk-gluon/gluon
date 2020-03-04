local funcs = {}

function funcs.config_message(config, _, ...)
--	config(...)
end

function funcs.config_package(config, pkg, value)
--	config('CONFIG_PACKAGE_%s=%s', pkg, value)
end

local lib = dofile('scripts/target_config_lib.lua')(funcs)


local output = {}

--for _,dev in pairs(lib.devices) do
--	io.stderr:write(string.format("target_config_profile.lua:device# %s\n", dev.name))
--	table.insert(output, get_pkglist(dev))
--	output[dev.name] = get_pkglist(dev)
--end
output = get_pkglist()
--table.sort(output)

--io.stderr:write(string.format("target_config_profile.lua:final# %s\n", dev.name))
	pkglist = io.open(string.format("%s/%s-%s.packages", lib.env.GLUON_TMPDIR, lib.env.BOARD, lib.env.SUBTARGET), "w")
for _, dev in ipairs(output) do
--	io.stderr:write(string.format("target_config_profile.lua:final# %s\n", dev[1]))
--    for board, pkglist in pairs(dev) do
--        print('\t', board, pkglist)
--    end
	io.stderr:write(string.format("target_config_profile.lua:final# device: '%s'; pkgs: '%s’\n", dev[1], dev[2]))
--	pkglist = io.open(string.format("%s/%s.packages", lib.env.GLUON_TMPDIR, dev[1]), "w")
	pkglist:write(string.format("%s:%s\n", dev [1], dev[2]))

end
	pkglist:close()


