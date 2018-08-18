local function check_peer(k)
	need_alphanumeric_key(k)

	need_string_match(in_domain(extend(k, {'key'})), '[%w]+=*')
	need_string_match(in_domain(extend(k, {'remote'})), '[%w_-.]')
	need_number(in_domain(extend(k, {'broker_port'})), false)
end

local function check_group(k)
	need_alphanumeric_key(k)

	need_number(extend(k, {'limit'}), false)
	need_table(extend(k, {'peers'}), check_peer, false)
	need_table(extend(k, {'groups'}), check_group, false)
end

need_table({'mesh_vpn', 'wireguard', 'groups'}, check_group)
