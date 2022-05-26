local branches = table_keys(need_table({'autoupdater', 'branches'}, function(branch)
	need_alphanumeric_key(branch)

	need_string(in_site(extend(branch, {'name'})))
	need_string_array_match(extend(branch, {'mirrors'}), '^http://')

	local pubkeys = need_string_array_match(in_site(extend(branch, {'pubkeys'})), '^%x+$')
	need_number(in_site(extend(branch, {'good_signatures'})))
	need(in_site(extend(branch, {'good_signatures'})), function(good_signatures)
		return good_signatures <= #pubkeys
	end, nil, string.format('be less than or equal to the number of public keys (%d)', #pubkeys))

	obsolete(in_site(extend(branch, {'probability'})), 'Use GLUON_PRIORITY in site.mk instead.')
end))

need_one_of(in_site({'autoupdater', 'branch'}), branches, false)

-- Check GLUON_AUTOUPDATER_BRANCH
local default_branch
local f = io.open((os.getenv('IPKG_INSTROOT') or '') .. '/lib/gluon/autoupdater/default_branch')
if f then
	default_branch = f:read('*line')
	f:close()
end
need_one_of(value('GLUON_AUTOUPDATER_BRANCH', default_branch), branches, false)
