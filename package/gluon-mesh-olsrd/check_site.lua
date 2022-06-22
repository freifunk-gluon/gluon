need_string_match(in_domain({'next_node', 'ip6'}), '^[%x:]+$', false)
need_string_match(in_domain({'next_node', 'ip4'}), '^%d+.%d+.%d+.%d+$', false)

need_boolean({'mesh', 'olsrd', 'v2', 'enable'}, false)
need_table({'mesh', 'olsrd', 'v2', 'config'}, nil, false)
