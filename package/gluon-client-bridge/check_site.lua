need_string_match('next_node.mac', '^%x[02468aAcCeE]:%x%x:%x%x:%x%x:%x%x:%x%x$')

if need_string_match('next_node.ip4', '^%d+.%d+.%d+.%d+$', false) then
  need_string_match('prefix4', '^%d+.%d+.%d+.%d+/%d+$')
end

need_string_match('next_node.ip6', '^[%x:]+$', false)


for _, config in ipairs({'wifi24', 'wifi5'}) do
   if need_table(config .. '.ap', nil, false) then
      need_string(config .. '.ap.ssid')
      need_boolean(config .. '.ap.disabled', false)
   end
end
