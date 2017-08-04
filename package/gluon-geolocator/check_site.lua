if need_table('geolocator', nil, false) then
  need_number('geolocator.autolocation', false)
  need_number('geolocator.interval', false)
  need_string_array_match('geolocator.blacklist', '^%w+:%w+:%w+:%w+:%w+:%w+$', false)
end
