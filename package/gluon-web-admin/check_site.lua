if need_table('config_mode', nil, false) and need_table('config_mode.remote_login', nil, false) then
  need_boolean('config_mode.remote_login.show_password_form', false)
  need_number('config_mode.remote_login.min_password_length', false)
end
