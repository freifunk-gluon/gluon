need_string_match(in_domain({'next_node', 'mac'}), '^%x[02468aAcCeE]:%x%x:%x%x:%x%x:%x%x:%x%x$', false)

if need_string_match(in_domain({'next_node', 'ip4'}), '^%d+.%d+.%d+.%d+$', false) then
	need_string_match(in_domain({'prefix4'}), '^%d+.%d+.%d+.%d+/%d+$')
end

need_string_match(in_domain({'next_node', 'ip6'}), '^[%x:]+$', false)


for _, config in ipairs({'wifi24', 'wifi5'}) do
	if need_table({config, 'ap'}, nil, false) then
		need_boolean({config, 'ap', 'disabled'}, false)
		if need_boolean({config, 'ap', 'owe_transition_mode'}, false) then
			need_string_match(in_domain({config, 'ap', 'ssid'}), '^' .. ('.?'):rep(32) .. '$')
			need_string_match(in_domain({config, 'ap', 'owe_ssid'}), '^' .. ('.?'):rep(32) .. '$')
		else
			need_string_match(in_domain({config, 'ap', 'ssid'}), '^' .. ('.?'):rep(32) .. '$', false)
			need_string_match(in_domain({config, 'ap', 'owe_ssid'}), '^' .. ('.?'):rep(32) .. '$', false)
		end
	end
end
