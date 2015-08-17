for _, config in ipairs({'wifi24', 'wifi5'}) do
   if need_table(config .. '.ap', nil, false) then
      need_string(config .. '.ap.ssid')
      need_boolean(config .. '.ap.disabled', false)
   end
end
