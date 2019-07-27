-- mesh/vxlan is required in single domain setups (this_domain() is nil)
need_boolean(in_domain({'mesh', 'vxlan'}), not this_domain())

need_number({'mesh', 'batman_adv', 'gw_sel_class'}, false)
need_one_of({'mesh', 'batman_adv', 'routing_algo'}, {'BATMAN_IV', 'BATMAN_IV_LEGACY', 'BATMAN_V'}, false)

local has_batman_adv = (os.execute('ls "$IPKG_INSTROOT"/lib/modules/*/batman-adv.ko >/dev/null 2>&1') == 0)
local has_batman_adv_legacy = (os.execute('ls "$IPKG_INSTROOT"/lib/modules/*/batman-adv-legacy.ko >/dev/null 2>&1') == 0)
local routing_algo = need_string({'mesh', 'batman_adv', 'routing_algo'}, false)
local path = conf_src({'mesh', 'batman_adv', 'routing_algo'})

if routing_algo == 'BATMAN_IV_LEGACY' then
	if not has_batman_adv_legacy then
		error(path .. " error: BATMAN_IV_LEGACY selected, but package 'gluon-mesh-batman-adv-14' was not", 0)
	end
elseif routing_algo == 'BATMAN_V' then
	if not has_batman_adv then
		error(path .. " error: BATMAN_V selected, but package 'gluon-mesh-batman-adv-15' was not", 0)
	end
else -- BATMAN_IV
	if not has_batman_adv and has_batman_adv_legacy then
		error(path .. " error: BATMAN_IV selected, but package 'gluon-mesh-batman-adv-15' was not (did you mean 'BATMAN_IV_LEGACY'?)", 0)
	elseif not has_batman_adv then
		error(path .. " error: BATMAN_IV selected, but package 'gluon-mesh-batman-adv-15' was not", 0)
	end
end
