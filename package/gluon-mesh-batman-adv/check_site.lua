-- mesh/vxlan is required in single domain setups (this_domain() is nil)
need_boolean(in_domain({'mesh', 'vxlan'}), not this_domain())

need_number({'mesh', 'batman_adv', 'gw_sel_class'}, false)


local allowed_algos = {}
local has_compat_14 = (os.execute('exec ls "$IPKG_INSTROOT"/lib/gluon/mesh-batman-adv/compat-14 >/dev/null 2>&1') == 0)
local has_compat_15 = (os.execute('exec ls "$IPKG_INSTROOT"/lib/gluon/mesh-batman-adv/compat-15 >/dev/null 2>&1') == 0)

if has_compat_14 then
	table.insert(allowed_algos, 'BATMAN_IV_LEGACY')
end
if has_compat_15 then
	table.insert(allowed_algos, 'BATMAN_IV')
	table.insert(allowed_algos, 'BATMAN_V')
end

need_one_of({'mesh', 'batman_adv', 'routing_algo'}, allowed_algos)
