for _, config in ipairs({'wifi24', 'wifi5'}) do
   if need_table(config .. '.ibss', nil, false) then
      need_string(config .. '.ibss.ssid')
      need_string_match(config .. '.ibss.bssid', '^%x[02468aAcCeE]:%x%x:%x%x:%x%x:%x%x:%x%x$')
      need_number(config .. '.ibss.mcast_rate', false)
      need_number(config .. '.ibss.vlan', false)
      need_boolean(config .. '.ibss.disabled', false)
   end

   if need_table(config .. '.mesh', nil, false) then
      need_string(config .. '.mesh.id')
      need_number(config .. '.mesh.mcast_rate', false)
      need_boolean(config .. '.mesh.disabled', false)
   end
end

need_boolean('mesh_on_wan', false)
need_boolean('mesh_on_lan', false)

if need_table('mesh', nil, false) and  need_table('mesh.batman_adv', nil, false) then
   need_number('mesh.batman_adv.gw_sel_class', false)
end
