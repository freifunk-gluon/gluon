local valid_domain_codes = table_keys(need_table(in_domain({'domain_names'})))

alternatives(function()
	need_boolean(in_domain({'hide_domain'}), false)
end, function()
	need_array_of(in_domain({'hide_domain'}), valid_domain_codes, false)
end)
