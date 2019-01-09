if need_table(in_domain({'domain_switch'}), check_domain_switch, false) then
	need_domain_name(in_domain({'domain_switch', 'target_domain'}))
	need_number(in_domain({'domain_switch', 'switch_after_offline_mins'}))
	need_number(in_domain({'domain_switch', 'switch_time'}))
	need_string_array_match(in_domain({'domain_switch', 'connection_check_targets'}), '^[%x:]+$')
end
