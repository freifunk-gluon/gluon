for _, config in ipairs({'wifi24', 'wifi5'}) do
   local rates = {1000, 2000, 5500, 6000, 9000, 11000, 12000, 18000, 24000, 36000, 48000, 54000}
   rates = need_array_of(config .. '.supported_rates', rates, false) or rates

   if need_table(config .. '.ibss', nil, false) then
      need_string(config .. '.ibss.ssid')
      need_string_match(config .. '.ibss.bssid', '^%x[02468aAcCeE]:%x%x:%x%x:%x%x:%x%x:%x%x$')
      need_one_of(config .. '.ibss.mcast_rate', rates, false)
      need_number(config .. '.ibss.vlan', false)
      need_boolean(config .. '.ibss.disabled', false)
   end

   if need_table(config .. '.mesh', nil, false) then
      need_string(config .. '.mesh.id')
      need_one_of(config .. '.mesh.mcast_rate', rates, false)
      need_boolean(config .. '.mesh.disabled', false)
   end
end

need_boolean('mesh_on_wan', false)
need_boolean('mesh_on_lan', false)

if need_table('mesh', nil, false) and  need_table('mesh.batman_adv', nil, false) then
   need_number('mesh.batman_adv.gw_sel_class', false)
end
