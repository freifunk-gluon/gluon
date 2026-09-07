-- prefix4 / prefix6 enable olsrd per family, config adds to the generated one
need_table({'mesh', 'olsrd', 'v4', 'config'}, nil, false)
need_table({'mesh', 'olsrd', 'v6', 'config'}, nil, false)

-- the node IPv4 address comes from node_prefix4, prefix4 otherwise
if need_string_match({'node_prefix4'}, '^%d+.%d+.%d+.%d+/%d+$', false) then
	need_number({'node_prefix4_range'}, true)
end
