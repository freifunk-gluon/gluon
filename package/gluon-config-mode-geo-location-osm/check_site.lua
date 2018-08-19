need_number(in_site({'config_mode', 'geo_location', 'osm', 'center', 'lon'}))
need_number(in_site({'config_mode', 'geo_location', 'osm', 'center', 'lat'}))
need_number(in_site({'config_mode', 'geo_location', 'osm', 'zoom'}), false)
need_string(in_site({'config_mode', 'geo_location', 'osm', 'openlayers_url'}), false)
