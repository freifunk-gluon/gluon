need_string(in_site('autoupdater.branch'))

local function check_branch(k, _)
   assert_uci_name(k)

   local prefix = string.format('autoupdater.branches[%q].', k)

   need_string(in_site(prefix .. 'name'))
   need_string_array_match(prefix .. 'mirrors', '^http://')
   need_number(in_site(prefix .. 'good_signatures'))
   need_string_array_match(in_site(prefix .. 'pubkeys'), '^%x+$')
end

need_table('autoupdater.branches', check_branch)
