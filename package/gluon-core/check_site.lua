need_string(in_site({'site_code'}))
need_string(in_site({'site_name'}))

-- this_domain() returns nil when multidomain support is disabled
if this_domain() then
	need_domain_name(in_site({'default_domain'}))

	need_table(in_domain({'domain_names'}), function(domain)
		need_alphanumeric_key(domain)
		need_string(domain)
	end)
	need_string(in_domain({'domain_names', this_domain()}))
end

need_string_match(in_domain({'domain_seed'}), '^' .. ('%x'):rep(64) .. '$')

need_string({'opkg', 'openwrt'}, false)
obsolete({'opkg', 'lede'}, 'Use opkg.openwrt instead.')
need_table({'opkg', 'extra'}, function(extra_repo)
	need_alphanumeric_key(extra_repo)
	need_string(extra_repo)
end, false)

need_string(in_site({'hostname_prefix'}), false)
need_string(in_site({'timezone'}))

need_string_array({'ntp_servers'}, false)

need_string_match(in_domain({'prefix6'}), '^[%x:]+/64$')

local supported_rates = {6000, 9000, 12000, 18000, 24000, 36000, 48000, 54000}
for _, config in ipairs({'wifi24', 'wifi5'}) do
	if need_table({config}, nil, false) then
		need_string(in_site({'regdom'})) -- regdom is only required when wifi24 or wifi5 is configured

		need_number({config, 'channel'})
		if config == 'wifi5' then
			need_string_match({config, 'outdoor_chanlist'}, '^[%d%s-]+$', false)
		end

		obsolete({config, 'supported_rates'}, '802.11b rates are disabled by default.')
		obsolete({config, 'basic_rate'}, '802.11b rates are disabled by default.')

		if need_table({config, 'ibss'}, nil, false) then
			need_string_match(in_domain({config, 'ibss', 'ssid'}), '^' .. ('.?'):rep(32) .. '$')
			need_string_match(in_domain({config, 'ibss', 'bssid'}), '^%x[02468aAcCeE]:%x%x:%x%x:%x%x:%x%x:%x%x$')
			need_one_of({config, 'ibss', 'mcast_rate'}, supported_rates, false)
			need_number({config, 'ibss', 'vlan'}, false)
			need_boolean({config, 'ibss', 'disabled'}, false)
		end

		if need_table({config, 'mesh'}, nil, false) then
			need_string_match(in_domain({config, 'mesh', 'id'}), '^' .. ('.?'):rep(32) .. '$')
			need_one_of({config, 'mesh', 'mcast_rate'}, supported_rates, false)
			need_boolean({config, 'mesh', 'disabled'}, false)
		end
	end
end

need_boolean(in_site({'poe_passthrough'}), false)

if need_table({'dns'}, nil, false) then
	need_string_array_match({'dns', 'servers'}, '^[%x:]+$')
end

need_string_array(in_domain({'next_node', 'name'}), false)
need_string_match(in_domain({'next_node', 'ip6'}), '^[%x:]+$', false)
need_string_match(in_domain({'next_node', 'ip4'}), '^%d+.%d+.%d+.%d+$', false)

need_boolean(in_domain({'mesh', 'vxlan'}), false)

need_boolean(in_site({'mesh_on_wan'}), false)
need_boolean(in_site({'mesh_on_lan'}), false)
need_boolean(in_site({'single_as_lan'}), false)
