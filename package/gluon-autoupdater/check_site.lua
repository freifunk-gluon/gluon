need_string 'autoupdater.branch'

local function check_branch(k, _)
   local prefix = string.format('autoupdater.branches[%q].', k)

   need_string(prefix .. 'name')
   need_string_array(prefix .. 'mirrors')
   need_number(prefix .. 'good_signatures')
   need_string_array(prefix .. 'pubkeys')
end

need_table('autoupdater.branches', check_branch)
