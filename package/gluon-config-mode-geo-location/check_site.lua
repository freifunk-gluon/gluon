if need_table(in_site('config_mode'), nil, false) and need_table(in_site('config_mode.geo_location'), nil, false) then
  need_boolean(in_site('config_mode.geo_location.show_altitude'), false)
end
