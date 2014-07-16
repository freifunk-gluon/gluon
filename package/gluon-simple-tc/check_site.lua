local function check_entry(k, _)
   local prefix = string.format('simple_tc[%q].', k)

   need_string(prefix .. 'ifname')
   need_boolean(prefix .. 'enabled')
   need_number(prefix .. 'limit_egress')
   need_number(prefix .. 'limit_ingress')
end

need_table('simple_tc', check_entry)
