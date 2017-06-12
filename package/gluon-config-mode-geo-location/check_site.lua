if need_table('config_mode', nil, false) and need_table('config_mode.geo_location', nil, false) then
  need_boolean('config_mode.geo_location.show_altitude', false)
end
