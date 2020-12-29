local function check_target(t)
	need_string_array_match(t, '^[%x:]+$', false)
end

need_table(in_domain({'check_connection', 'targets'}), check_target, false)
