-- mesh/vxlan is required in single domain setups (this_domain() is nil)
need_boolean(in_domain({'mesh', 'vxlan'}), not this_domain())

need_number(in_site_or_domain({'mesh', 'batman_adv', 'gw_sel_class'}), false)
need_one_of(in_site_or_domain({'mesh', 'batman_adv', 'routing_algo'}), {'BATMAN_IV', 'BATMAN_V'})
