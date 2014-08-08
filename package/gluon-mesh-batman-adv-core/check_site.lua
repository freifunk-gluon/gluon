need_string('regdom')

for _, config in ipairs({'wifi24', 'wifi5'}) do
   need_string(config .. '.ssid')
   need_number(config .. '.channel')
   need_string(config .. '.htmode')
   need_string(config .. '.mesh_ssid')
   need_string_match(config .. '.mesh_bssid', '^%x[02468aAcCeE]:%x%x:%x%x:%x%x:%x%x:%x%x$')
   need_number(config .. '.mesh_mcast_rate')
end

need_boolean('mesh_on_wan', false)
