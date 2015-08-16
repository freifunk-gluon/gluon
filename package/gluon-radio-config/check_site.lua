need_string('regdom')

for _, config in ipairs({'wifi24', 'wifi5'}) do
   need_number(config .. '.channel')
   need_string(config .. '.htmode')
end
