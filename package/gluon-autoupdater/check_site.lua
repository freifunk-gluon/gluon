need_string 'autoupdater.branch'

local function check_branch(k, _)
   assert_uci_name(k)

   local prefix = string.format('autoupdater.branches[%q].', k)

   need_string(prefix .. 'name')
   need_string_array_match(prefix .. 'mirrors', '^http://')
   need_number(prefix .. 'good_signatures')
   need_string_array_match(prefix .. 'pubkeys', '^%x+$')
end

need_table('autoupdater.branches', check_branch)
