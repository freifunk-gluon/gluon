need_string_match(in_domain({'prefix6'}), '^[%x:]+/64$', true)
need_string_match(in_domain({'node_client_prefix6'}), '^[%x:]+/64$', false)
need_string_match(in_domain({'prefix4'}), '^%d+.%d+.%d+.%d+/%d+$', false)
