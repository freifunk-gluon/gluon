local fastd_methods = {'salsa2012+gmac', 'salsa2012+umac', 'null+salsa2012+gmac', 'null+salsa2012+umac', 'null'}
need_array_of('mesh_vpn.fastd.methods', fastd_methods)
need_boolean(in_site('mesh_vpn.fastd.configurable'), false)

need_one_of(in_site('mesh_vpn.fastd.syslog_level'), {'error', 'warn', 'info', 'verbose', 'debug', 'debug2'}, false)

local function check_peer(prefix)
	return function(k, _, conf_name)
		assert_uci_name(k, conf_name)

		local table = string.format('%s[%q].', prefix, k)

		need_string_match(table .. 'key', '^%x+$')
		need_string_array(in_domain(table .. 'remotes'))
	end
end

local function check_group(prefix)
	return function(k, _, conf_name)
		assert_uci_name(k, conf_name)

		local table = string.format('%s[%q].', prefix, k)

		need_number(table .. 'limit', false)
		need_table(table .. 'peers', check_peer(table .. 'peers'), false)
		need_table(table .. 'groups', check_group(table .. 'groups'), false)
	end
end

need_table('mesh_vpn.fastd.groups', check_group('mesh_vpn.fastd.groups'))
