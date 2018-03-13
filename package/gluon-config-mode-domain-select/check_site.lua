need_boolean(in_domain({'hide_domain'}), false)
need_array_of(in_domain({'hide_domain_codes'}), table_keys(need_table(in_domain({'domain_names'}), nil, true)), false)
