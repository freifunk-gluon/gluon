need_boolean(in_domain({'hide_domain'}), false)
valid_domain_codes = table_keys(need_table(in_domain({'domain_names'})))
need_array_of(in_domain({'hide_domain_codes'}), valid_domain_codes, false)
