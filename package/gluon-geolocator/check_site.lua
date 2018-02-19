need_boolean(in_site({'geolocator', 'autolocation'}), false)
need_number(in_site({'geolocator', 'interval'}), false)
need_string_array_match(in_site({'geolocator', 'blacklist'}), '^%w+:%w+:%w+:%w+:%w+:%w+$')
