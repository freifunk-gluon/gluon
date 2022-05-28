if need_boolean({'mesh', 'olsrd', 'v1_6', 'enable'}, false) then
  need_table({'mesh', 'olsrd', 'v1_6', 'config'}, nil, false)
end

if need_boolean({'mesh', 'olsrd', 'v1_4', 'enable'}, false) then
  need_table({'mesh', 'olsrd', 'v1_4', 'config'}, nil, false)
end

if need_boolean({'mesh', 'olsrd', 'v2', 'enable'}, false) then
  need_table({'mesh', 'olsrd', 'v2', 'config'}, nil, false)
  need_boolean({'mesh', 'olsrd', 'v2', 'ip6_exclusive_mode'}, false)
  need_boolean({'mesh', 'olsrd', 'v2', 'ip4_exclusive_mode'}, false)
  if need_boolean({'mesh', 'olsrd', 'v2', 'ip4_exclusive_mode'}, false) and need_boolean({'mesh', 'olsrd', 'v2', 'ip6_exclusive_mode'}, false) then
    -- FIXME: we could check the value but idk how to do that. basically both options are xor.
    error('you cant enable both olsrv2 ip4 and ip6 exclusive mode')
  end
end
