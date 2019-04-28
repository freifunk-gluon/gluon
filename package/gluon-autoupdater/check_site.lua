need_string(in_site({'autoupdater', 'branch'}))

need_table({'autoupdater', 'branches'}, function(branch)
	need_alphanumeric_key(branch)

	need_string(in_site(extend(branch, {'name'})))
	need_string_array_match(extend(branch, {'mirrors'}), '^http://')
	need_number(in_site(extend(branch, {'good_signatures'})))
	need_string_array_match(in_site(extend(branch, {'pubkeys'})), '^%x+$')
	obsolete(in_site(extend(branch, {'probability'})), 'Use GLUON_PRIORITY in site.mk instead.')
end)
