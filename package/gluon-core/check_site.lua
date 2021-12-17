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

need_string_match(in_domain({'prefix4'}), '^%d+.%d+.%d+.%d+/%d+$', false)
need_string_match(in_domain({'prefix6'}), '^[%x:]+/64$')
need_string_array_match(in_domain({'extra_prefixes6'}), '^[%x:]+/%d+$', false)

local supported_rates = {6000, 9000, 12000, 18000, 24000, 36000, 48000, 54000}
for _, config in ipairs({'wifi24', 'wifi5'}) do
	if need_table({config}, nil, false) then
		need_string(in_site({'regdom'})) -- regdom is only required when wifi24 or wifi5 is configured
		need_number({config, 'beacon_interval'}, false)

		if config == "wifi24" then
			local channels = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14}
			need_one_of({config, 'channel'}, channels)
		elseif config == 'wifi5' then
			local channels = {
				34, 36, 38, 40, 42, 44, 46, 48, 50, 52, 54, 56, 58, 60, 62,
				64, 96, 100, 102, 104, 106, 108, 110, 112, 114, 116, 118,
				120, 122, 124, 126, 128, 132, 134, 136, 138, 140, 142, 144,
				149, 151, 153, 155, 157, 159, 161, 165, 169, 173 }
			need_one_of({config, 'channel'}, channels)
			need_chanlist({config, 'outdoor_chanlist'}, channels, false)
			need_one_of({config, 'outdoors'}, {true, false, 'preset'}, false)
		end

		obsolete({config, 'supported_rates'}, '802.11b rates are disabled by default.')
		obsolete({config, 'basic_rate'}, '802.11b rates are disabled by default.')
		obsolete({config, 'ibss'}, 'IBSS support has been dropped.')

		if need_table({config, 'mesh'}, nil, false) then
			need_string_match(in_domain({config, 'mesh', 'id'}), '^' .. ('.?'):rep(32) .. '$')
			need_one_of({config, 'mesh', 'mcast_rate'}, supported_rates, false)
			need_boolean({config, 'mesh', 'disabled'}, false)
		end
	end
end

need_boolean(in_site({'poe_passthrough'}), false)

if need_table({'dns'}, nil, false) then
	-- need_string_array_match({'dns', 'servers'}, '^[%x:]+$')
end

need_string_array(in_domain({'next_node', 'name'}), false)
need_string_match(in_domain({'next_node', 'ip6'}), '^[%x:]+$', false)
need_string_match(in_domain({'next_node', 'ip4'}), '^%d+.%d+.%d+.%d+$', false)

need_boolean(in_domain({'mesh', 'vxlan'}), false)

local interfaces_roles = {'client', 'uplink', 'mesh'}
for _, config in ipairs({'wan', 'lan', 'single'}) do
	need_array_of(in_site({'interfaces', config, 'default_roles'}), interfaces_roles, false)
end

obsolete({'mesh_on_wan'}, 'Use interfaces.wan.default_roles.')
obsolete({'mesh_on_lan'}, 'Use interfaces.lan.default_roles.')
obsolete({'single_as_lan'}, 'Use interfaces.single.default_roles.')
