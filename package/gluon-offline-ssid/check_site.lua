need_boolean({'offline_ssid', 'disabled'}, false)
need_number({'offline_ssid', 'switch_timeframe'}, false)
need_number({'offline_ssid', 'first'}, false)
need_string({'offline_ssid', 'prefix'}, false)
need_one_of({'offline_ssid', 'suffix'}, {'nodename', 'mac', 'none'}, false)
if need_boolean({'offline_ssid','tq_limit_enabled'}, false) then
  need_number({'offline_ssid', 'tq_limit_max'}, false)
  need_number({'offline_ssid', 'tq_limit_min'}, false)
end
