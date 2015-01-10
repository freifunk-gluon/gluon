local function check_role(k, _)
   local role = string.format('roles.list[%q]', k)

   need_string(role)
end

need_string('roles.default')
need_table('roles.list', check_role)
