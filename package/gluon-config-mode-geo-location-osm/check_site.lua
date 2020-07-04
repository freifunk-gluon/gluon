need_number(in_site({'config_mode', 'geo_location', 'osm', 'center', 'lon'}))
need_number(in_site({'config_mode', 'geo_location', 'osm', 'center', 'lat'}))
need_number(in_site({'config_mode', 'geo_location', 'osm', 'zoom'}), false)
need_string(in_site({'config_mode', 'geo_location', 'osm', 'openlayers_url'}), false)

if need_table(in_site({'config_mode', 'geo_location', 'osm', 'tile_layer'}), nil, false) then
	need_one_of(in_site({'config_mode', 'geo_location', 'osm', 'tile_layer', 'type'}), {'XYZ'})
	need_string(in_site({'config_mode', 'geo_location', 'osm', 'tile_layer', 'url'}))
	need_string(in_site({'config_mode', 'geo_location', 'osm', 'tile_layer', 'attributions'}))
end
