local function check_peer(k)
	need_alphanumeric_key(k)

	need_string_match(in_domain(extend(k,
		{'public_key'})), "^" .. ("[%a%d+/]"):rep(42) .. "[AEIMQUYcgkosw480]=$")
	need_string(in_domain(extend(k, {'endpoint'})))
end

need_table({'mesh_vpn', 'wireguard', 'peers'}, check_peer)
need_number({'mesh_vpn', 'wireguard', 'mtu'})
