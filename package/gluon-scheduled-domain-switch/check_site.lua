if need_table(in_domain({'domain_switch'}), nil, false) then
	need_domain_name(in_domain({'domain_switch', 'target_domain'}))
	need_number(in_domain({'domain_switch', 'switch_after_offline_mins'}))
	need_number(in_domain({'domain_switch', 'switch_time'}))
	obsolete({'domain_switch', 'connection_check_targets'},
	'Connections to NTP servers and gateways are used for this now.')
end
