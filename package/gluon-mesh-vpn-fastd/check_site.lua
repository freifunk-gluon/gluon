local fastd_methods = {'salsa2012+umac', 'null+salsa2012+umac', 'null'}
need_array_of({'mesh_vpn', 'fastd', 'methods'}, fastd_methods)
need_boolean(in_site({'mesh_vpn', 'fastd', 'configurable'}), false)

need_one_of(in_site({'mesh_vpn', 'fastd', 'syslog_level'}),
	{'error', 'warn', 'info', 'verbose', 'debug', 'debug2'}, false)

local function check_peer(k)
	need_alphanumeric_key(k)

	need_string_match(in_domain(extend(k, {'key'})), '^%x+$')
	need_string_array(in_domain(extend(k, {'remotes'})))
end

local function check_group(k)
	need_alphanumeric_key(k)

	need_number(extend(k, {'limit'}), false)
	need_table(extend(k, {'peers'}), check_peer, false)
	need_table(extend(k, {'groups'}), check_group, false)
end

need_table({'mesh_vpn', 'fastd', 'groups'}, check_group)
