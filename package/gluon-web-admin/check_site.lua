if need_table(in_site('config_mode'), nil, false) and need_table(in_site('config_mode.remote_login'), nil, false) then
  need_boolean(in_site('config_mode.remote_login.show_password_form'), false)
  need_number(in_site('config_mode.remote_login.min_password_length'), false)
end
